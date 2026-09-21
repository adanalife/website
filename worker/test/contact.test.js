import test from 'node:test'
import assert from 'node:assert/strict'
import { contactMail } from '../src/index.js'

const form = (fields) => new URLSearchParams(fields)

test('contact form: reply-to the visitor, subject from the message', () => {
  const m = contactMail(form({ message: 'hi  there\nfriend', email: 'v@example.com' }))
  assert.equal(m.replyTo, 'v@example.com')
  assert.equal(m.subject, '[dana.lol contact] hi there friend')
  assert.match(m.text, /from: v@example.com/)
})

test('ama form: no email field means no reply-to and the ama label', () => {
  const m = contactMail(form({ message: 'why a van?' }))
  assert.equal(m.replyTo, undefined)
  assert.equal(m.subject, '[dana.lol ama] why a van?')
})

test('blank email is not a reply-to; junk email is not a reply-to', () => {
  assert.equal(contactMail(form({ message: 'x', email: '' })).replyTo, undefined)
  assert.equal(contactMail(form({ message: 'x', email: 'not-an-email' })).replyTo, undefined)
})

test('empty message or a filled honeypot is dropped', () => {
  assert.equal(contactMail(form({ message: '   ' })), null)
  assert.equal(contactMail(form({ message: 'buy stuff', website: 'http://spam' })), null)
})
