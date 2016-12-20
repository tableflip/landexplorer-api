import { mockServer } from 'graphql-tools'
import schema from '../data/schema'
import test from 'tape'

const server = mockServer(schema)

test('Should return an inspireid for a lng lat', (t) => {
  t.plan(1)

  server.query(`{inspireId(lng: -1.25390, lat: 51.76110)}`)
  .then((result) => {
    t.equal(result.data.inspireId, 27567047, 'lng: -1.25390, lat: 51.76110 resolves to 27567047')
    t.end()
  })
})

test('Should return not found if lng lat is outside uk', (t) => {
  t.plan(2)

  server.query(`{inspireId(lng: 2.3473386, lat: 51.0415219)}`)
    .then((result) => {
      t.ok(result.error, 'Returns error object in result ok')
      t.equal(result.error.message, 'Not found', 'Not found message')
      t.end()
    })
})
