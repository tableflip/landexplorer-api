import Sequelize from 'sequelize'
import { postgres } from 'config'

const db = new Sequelize(postgres.db, postgres.username, postgres.password, {
  host: postgres.host,
  dialect: 'postgres',
  pool: {
    max: 5,
    min: 1,
    idle: 10000 // ms
  }
})

const findInspireId = ({lng, lat}) => {
  const query = `
  SELECT inspireid
  FROM landregistry.inspire i
  WHERE ST_Covers(
    i.boundary,
    ST_GeographyFromText('POINT(${lng} ${lat})')
  );`
  return db
    .query(query, { type: db.QueryTypes.SELECT })
    .then((rows) => rows.map((r) => r.inspireid))
}

export { findInspireId, db }
