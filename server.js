import express from 'express'
import Schema from './data/schema'
import Resolvers from './data/resolvers'
import Connectors from './data/connectors'
import { apolloExpress, graphiqlExpress } from 'apollo-server'
import { makeExecutableSchema } from 'graphql-tools'
import bodyParser from 'body-parser'

const GRAPHQL_PORT = 8080

const graphQLServer = express()

const executableSchema = makeExecutableSchema({
  typeDefs: Schema,
  resolvers: Resolvers,
  connectors: Connectors,
  allowUndefinedInResolve: true,
  printErrors: true
})

graphQLServer.use('/graphql', bodyParser.json(), apolloExpress({
  schema: executableSchema,
  context: {}
}))

graphQLServer.use('/graphiql', graphiqlExpress({
  endpointURL: '/graphql'
}))

graphQLServer.listen(GRAPHQL_PORT, () => console.log(
  `GraphQL Server is now running on http://localhost:${GRAPHQL_PORT}/graphql`
))
