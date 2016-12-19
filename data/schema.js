const typeDefinitions = `
  type Query {
    inspireId(lng: String, lat: String): String
  }

  schema {
    query: Query
  }
`

export default [typeDefinitions]
