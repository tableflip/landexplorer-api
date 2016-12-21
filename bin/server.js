import express from 'express'
import { graphqlExpress, graphiqlExpress } from 'graphql-server-express'
import { makeExecutableSchema } from 'graphql-tools'
import bodyParser from 'body-parser'
import config from 'config'
import cors from 'cors'

import Schema from '../data/schema'
import Resolvers from '../data/resolvers'
import Connectors from '../data/connectors'

const api = express()

const executableSchema = makeExecutableSchema({
  typeDefs: Schema,
  resolvers: Resolvers,
  connectors: Connectors,
  allowUndefinedInResolve: false,
  printErrors: true
})

api.use(cors())
api.options('*', cors())

api.use('/graphql', bodyParser.json(), graphqlExpress({
  schema: executableSchema,
  context: {}
}))

api.use('/graphiql', graphiqlExpress({
  endpointURL: '/graphql'
}))

api.listen(config.port, () => console.log(`GraphQL Server started http://${config.host}:${config.port}/graphql`))
