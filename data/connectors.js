
import Sequelize from 'sequelize'

const db = new Sequelize('inspire', null, null, {
  host: 'localhost',
  dialect: 'postgres',
  pool: {
    max: 5,
    min: 0,
    idle: 10000
  }
})

const InspireIdModel = db.define('inspireids', {
  inspireid: { type: Sequelize.INTEGER }
})

const InspireId = db.models.inspireids

export { InspireId, InspireIdModel }
