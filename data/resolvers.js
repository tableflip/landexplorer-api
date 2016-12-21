import { db } from './connectors'

const resolvers = {
  Query: {
    inspireId (_, args) {
      const { lng, lat } = args
      const query = `SELECT inspireid FROM predefined WHERE ST_Contains(ST_Transform(ST_SetSRID(wkb_geometry, 27700), 4326),ST_GeomFromText('POINT(${lng} ${lat})', 4326));`

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
