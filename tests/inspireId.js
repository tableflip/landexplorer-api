import test from 'tape'
import server from '../bin/server'

test('Start server', (t) => {
  t.plan(1)
  server((connection) => {
    t.ok(connection, 'server is running')
    connection.close(t.end)
  })
})
