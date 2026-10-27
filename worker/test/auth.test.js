import test from 'node:test'
import assert from 'node:assert/strict'
import worker from '../src/index.js'

const get = (auth) => new Request('https://inbox.example/messages', { headers: auth ? { authorization: auth } : {} })

test('inbox API refuses everything when INBOX_TOKEN is unset', async () => {
  const res = await worker.fetch(get('Bearer undefined'), {})
  assert.equal(res.status, 401)
})

test('inbox API refuses a wrong token', async () => {
  const res = await worker.fetch(get('Bearer nope'), { INBOX_TOKEN: 'secret' })
  assert.equal(res.status, 401)
})
