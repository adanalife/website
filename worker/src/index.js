// Two doors into one inbox. Every message becomes a directory in R2:
//
//   <id>/meta.json            {source, from, subject, body, date}
//   <id>/<n>-<filename>       each photo, in the order it arrived
//
// where <id> is time-sortable so the drain processes oldest first. The
// worker never touches pixels — the drain side runs script/ingest-image.
//
// A drained message is moved under archive/<id>/ rather than deleted: the
// photos as uploaded (full EXIF, no watermark) are the originals corpus,
// which is what lets the drain run anywhere — no NAS needed.
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

  // Door 2 + the drain API. Everything needs the bearer token.
  async fetch (request, env) {
    if (request.headers.get('authorization') !== `Bearer ${env.INBOX_TOKEN}`) {
      return new Response('unauthorized', { status: 401 })
    }
    const url = new URL(request.url)
    const { method } = request

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
          if (obj.key.startsWith('archive/')) continue
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

    // "Delete" = archive. R2 has no rename, so copy then delete.
    if (method === 'DELETE' && url.pathname.startsWith('/messages/')) {
      const prefix = url.pathname.slice('/messages/'.length) + '/'
      const page = await env.INBOX.list({ prefix })
      for (const o of page.objects) {
        const src = await env.INBOX.get(o.key)
        await env.INBOX.put(`archive/${o.key}`, src.body, { httpMetadata: src.httpMetadata })
      }
      await env.INBOX.delete(page.objects.map(o => o.key))
      return json({ archived: page.objects.length })
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

const json = (data, status = 200) =>
  new Response(JSON.stringify(data), { status, headers: { 'content-type': 'application/json' } })
