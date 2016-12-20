const config = require('config')
const exec = require('child_process').exec
const cmd = `ogr2ogr -f PostgreSQL PG:"host='localhost' port='5432' dbname='${config.db}'" -progress -nlt PROMOTE_TO_MULTI ${__dirname}/Land_Registry_Cadastral_Parcels.gml`

console.log(cmd)
