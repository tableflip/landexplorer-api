import express from 'express'
import { apolloExpress, graphiqlExpress } from 'apollo-server'
import { makeExecutableSchema } from 'graphql-tools'
import bodyParser from 'body-parser'
import config from 'config'

import Schema from '../data/schema'
import Resolvers from '../data/resolvers'
import Connectors from '../data/connectors'

export default (cb) => {
  const api = express()

  const executableSchema = makeExecutableSchema({
    typeDefs: Schema,
    resolvers: Resolvers,
    connectors: Connectors,
    allowUndefinedInResolve: false,
    printErrors: true
  })

  api.use('/graphql', bodyParser.json(), apolloExpress({
    schema: executableSchema,
    context: {}
  }))

  api.use('/graphiql', graphiqlExpress({
    endpointURL: '/graphql'
  }))

  const server = api.listen(config.port, () => {
    console.log(`GraphQL Server started http://${config.host}:${config.port}/graphql`)
    if (cb) cb(server)
  })
}
