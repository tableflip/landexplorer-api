import Sequelize from 'sequelize'
import config from 'config'

export default new Sequelize(config.db, null, null, {
  host: 'localhost',
  dialect: 'postgres',
  pool: {
    max: 1,
    min: 0,
    idle: 5000 // The maximum time, in milliseconds, that a connection can be idle before being released.
  }
})
