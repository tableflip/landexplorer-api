const config = require('config')
const exec = require('child_process').exec
const cmd = `ogr2ogr -f PostgreSQL PG:dbname=${config.db} -progress -nlt PROMOTE_TO_MULTI ${__dirname}/Land_Registry_Cadastral_Parcels.gml`

exec(cmd, (err, stdout, stderr) => {
  if (err) throw new Error(err)
  console.log('Seeded database with INSPIRE data for Oxford')
})
