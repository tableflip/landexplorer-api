import { db } from './connectors'

const resolvers = {
  Query: {
    inspireId (_, args) {
      const { lng, lat } = args
      const query = `
      SELECT inspireid
      FROM landregistry.inspire i
      WHERE ST_Covers(
        i.boundary,
        ST_GeographyFromText('POINT(${lng} ${lat})')
      );`
      return db.query(query, { type: db.QueryTypes.SELECT })
      .then((results) => {
        if (!results || !results[0]) return null
        return results[0].inspireid
      })
      .catch((err) => {
        console.error(err)
        throw new Error(err)
      })
    }
  }
}

export default resolvers
