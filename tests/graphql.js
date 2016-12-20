import { mockServer } from 'graphql-tools'
import schema from '../data/schema'
import test from 'tape'

const server = mockServer(schema)

test('Should return an inspireid for a lng lat', (t) => {
  t.plan(1)

  server.query(`{inspireId(lng: -1.25390, lat: 51.76110)}`)
  .then((result) => {
    t.ok(result.data.inspireId, 'returns inspireId')
    t.end()
  })
})

test('Should return not found if lng lat is outside uk', (t) => {
  t.plan(1)

  server.query(`{inspireId(lng: 2.3473386)}`)
    .then((result) => {
      t.ok(result.errors[0], 'Returns error object in result ok')
      t.end()
    })
})
