import test from 'tape'
import server from '../bin/server'
import request from 'request'
import async from 'async'
import config from 'config'

let connection = null

test('Start server', (t) => {
  t.plan(1)
  server((connected) => {
    connection = connected
    t.ok(connection, 'server Started')
    t.end()
  })
})

test('Should respond to a post request', (t) => {
  t.plan(1)

  async.waterfall([
    (cb) => {
      request.post({
        url: `http://${config.host}:${config.port}/graphql`,
        json: true
      }, (err, res) => cb(err, res))
    }
  ], (err, res) => {
    t.error(err, 'no errors')
    t.end()
  })
})

test('Server Stopped', (t) => {
  connection.close(() => {
    console.log('Server closed')
    t.end()
  })
})
