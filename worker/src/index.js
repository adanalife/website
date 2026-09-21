// Two doors into one inbox. Every message becomes a directory in R2:
//
//   <id>/meta.json            {source, from, subject, body, date}
//   <id>/<n>-<filename>       each photo, in the order it arrived
//
// where <id> is time-sortable so the drain processes oldest first. The
// worker never touches pixels — the drain side runs script/ingest-image.
import PostalMime from 'postal-mime'

export default {
  // Door 1: Cloudflare Email Routing hands post@ mail here.
  async email (message, env) {
    const allowed = env.ALLOWED_SENDERS.split(',').map(s => s.trim().toLowerCase())
    if (!allowed.includes(message.from.toLowerCase())) {
      message.setReject('address not accepted')
      return
    }
    const mail = await PostalMime.parse(message.raw)
    const photos = mail.attachments
      .filter(a => a.mimeType.startsWith('image/'))
      .map(a => ({ name: a.filename || 'photo.jpg', body: a.content, type: a.mimeType }))
    await store(env.INBOX, {
      source: 'email',
      from: message.from,
      subject: mail.subject || '',
      body: (mail.text || '').trim(),
      date: mail.date || new Date().toISOString()
    }, photos)
  },

  // Door 2 + the drain API. Everything but /contact needs the bearer token.
  async fetch (request, env) {
    const url = new URL(request.url)
    const { method } = request

    // Door 3: the dana.lol contact + AMA forms. Public, so it sits before the gate.
    if (url.pathname === '/contact') {
      if (method !== 'POST') return new Response('method not allowed', { status: 405 })
      const origin = request.headers.get('origin') || ''
      const cors = CONTACT_ORIGINS.test(origin) ? { 'access-control-allow-origin': origin } : {}
      const mail = contactMail(await request.formData())
      if (mail) await env.CONTACT.send(mail)
      // A dropped submission (empty or honeypot-tripped) still reads as success
      // so a bot learns nothing. The page's script only looks at res.ok; a
      // no-JS visitor lands on this JSON and has the page's mailto fallback.
      return json({ ok: true }, 200, cors)
    }

    if (request.headers.get('authorization') !== `Bearer ${env.INBOX_TOKEN}`) {
      return new Response('unauthorized', { status: 401 })
    }

    // iOS Shortcut: multipart form with `subject`, `body`, and files. A form
    // field holds one value in Shortcuts, so a multi-photo share arrives as
    // one request per photo carrying the same `id`; they join one message.
    if (method === 'POST' && url.pathname === '/') {
      const form = await request.formData()
      const photos = []
      for (const [, value] of form) {
        if (value instanceof File) photos.push({ name: value.name, body: await value.arrayBuffer(), type: value.type })
      }
      const id = await store(env.INBOX, {
        source: 'shortcut',
        from: '',
        subject: form.get('subject') || '',
        body: (form.get('body') || '').trim(),
        date: new Date().toISOString()
      }, photos, form.get('id')?.replace(/[^\w-]/g, ''))
      return json({ id, photos: photos.length })
    }

    if (method === 'GET' && url.pathname === '/messages') {
      const messages = {}
      let cursor
      do {
        const page = await env.INBOX.list({ cursor })
        for (const obj of page.objects) {
          const [id, ...rest] = obj.key.split('/')
          ;(messages[id] ??= []).push(rest.join('/'))
        }
        cursor = page.truncated ? page.cursor : undefined
      } while (cursor)
      return json(Object.entries(messages).sort().map(([id, files]) => ({ id, files })))
    }

    if (method === 'GET' && url.pathname.startsWith('/o/')) {
      const obj = await env.INBOX.get(url.pathname.slice(3))
      if (!obj) return new Response('not found', { status: 404 })
      return new Response(obj.body, { headers: { 'content-type': obj.httpMetadata?.contentType || 'application/octet-stream' } })
    }

    if (method === 'DELETE' && url.pathname.startsWith('/messages/')) {
      const prefix = url.pathname.slice('/messages/'.length) + '/'
      const page = await env.INBOX.list({ prefix })
      await env.INBOX.delete(page.objects.map(o => o.key))
      return json({ deleted: page.objects.length })
    }

    return new Response('not found', { status: 404 })
  }
}

async function store (bucket, meta, photos, id) {
  id ||= `${new Date().toISOString().replace(/[:.]/g, '-')}-${crypto.randomUUID().slice(0, 8)}`
  const existing = (await bucket.list({ prefix: `${id}/` })).objects.length
  if (existing === 0) await bucket.put(`${id}/meta.json`, JSON.stringify(meta), { httpMetadata: { contentType: 'application/json' } })
  const offset = Math.max(existing - 1, 0)
  await Promise.all(photos.map((p, i) =>
    bucket.put(`${id}/${String(offset + i + 1).padStart(2, '0')}-${p.name.replace(/[^\w.-]/g, '_')}`, p.body, { httpMetadata: { contentType: p.type } })
  ))
  return id
}

// Origins allowed to POST /contact cross-site: prod, staging, and per-PR previews.
const CONTACT_ORIGINS = /^https:\/\/(www\.dana\.lol|staging\.dana\.lol|www\.whalecore\.com|[\w-]+\.dana-lol-staging\.pages\.dev)$/

// Contact form: `message` + `email` (may be blank). AMA form: `message` only.
// `website` is a honeypot the pages hide; humans never fill it.
// Returns the send_email payload, or null when the submission should be dropped.
// ponytail: the honeypot is the whole spam defence; add Turnstile if bots find it
export function contactMail (form) {
  const message = (form.get('message') || '').trim().slice(0, 10000)
  if (!message || form.get('website')) return null
  const email = (form.get('email') || '').trim()
  const kind = form.has('email') ? 'contact' : 'ama'
  const mail = {
    to: 'danadotlol@gmail.com', // must match the binding's destination_address
    from: 'contact@whalecore.com',
    subject: `[dana.lol ${kind}] ${message.replace(/\s+/g, ' ').slice(0, 60)}`,
    text: `${message}\n\n--\nfrom: ${email || '(no email given)'}\nform: ${kind}\n`
  }
  if (/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) mail.replyTo = email
  return mail
}

const json = (data, status = 200, headers = {}) =>
  new Response(JSON.stringify(data), { status, headers: { 'content-type': 'application/json', ...headers } })
