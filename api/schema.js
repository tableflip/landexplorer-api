const typeDefinitions = `

type Query {
  inspireId(lng: Float!, lat: Float!): Int
}

schema {
  query: Query
}
`

export default [typeDefinitions]
