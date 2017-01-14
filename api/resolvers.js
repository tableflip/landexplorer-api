import { findInspireId } from '../lib/db'

const resolvers = {
  Query: {
    inspireId (_, {lng, lat}) {
      findInspireId({lng, lat})
      .catch((err) => {
        console.error(err)
        throw new Error(err)
      })
    }
  }
}

export default resolvers
