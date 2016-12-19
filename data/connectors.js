
import Sequelize from 'sequelize'

const db = new Sequelize('inspire', null, null, {
  host: 'localhost',
  dialect: 'postgres',
  pool: {
    max: 5,
    min: 0,
    idle: 10000 // The maximum time, in milliseconds, that a connection can be idle before being released.
  }
})

export { db }
