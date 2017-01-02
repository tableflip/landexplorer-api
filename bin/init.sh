#!/bin/bash

# Import INSPIRE index polygons into postgres

# - Convert source GML files into a db dump using `ogr2ogr`.
# - Create a db, schema and table as needed.
# - Import the data dump
# - Create the index (faster to do this once after import)
# - Vacuum db
#
# See:
# - https://www.gov.uk/guidance/inspire-index-polygons-spatial-data
# - ogr2ogr docs: http://www.gdal.org/drv_pg.html
# - optimal postgis import flow: http://longwayaround.org.uk/notes/loading-postgis/
# - http://revenant.ca/www/postgis/workshop/indexing.html
# - https://github.com/psd/landregistry-inspire-data/blob/1c239d0299d8b8c72bf48b854ce03155213b3281/Makefile#L21
# - http://linuxcommand.org/wss0150.php
# - http://stackoverflow.com/questions/760210/how-do-you-create-a-read-only-user-in-postgresql

#
# Usage:
# (As a user with super user db priviledges)
# ./init.sh --create-db
# parallel ./init.sh {} < files.txt
# ./init.sh --index

PROGNAME=$(basename $0)
ZIP=$1
NAME=${ZIP%.zip}
DB="landexplorer"
DB_USER="landexplorer-api"
SCHEMA="landregistry"
TABLE="inspire"
GEO_COLUMN_TYPE="geography"
GEO_COLUMN_NAME="boundary"
SOURCE_SRS="EPSG:27700"
TARGET_SRS="EPSG:4326"

# SQL to init postgis, schema and table.
# Note: Only a db superuser can create the postgis extention.
# Note: this is a `heredoc`. It'll read the multiline sql into the SQL var.)
read -r -d '' SQL << EOM
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SCHEMA IF NOT EXISTS $SCHEMA;
CREATE TABLE IF NOT EXISTS $SCHEMA.$TABLE (
  id serial PRIMARY KEY,
  $GEO_COLUMN_NAME geography(Polygon,4326) NOT NULL,
  inspireid integer NOT NULL
);
GRANT CONNECT ON DATABASE $DB TO "$DB_USER";
GRANT USAGE ON SCHEMA $SCHEMA TO "$DB_USER";
GRANT SELECT ON ALL TABLES IN SCHEMA $SCHEMA TO "$DB_USER";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA $SCHEMA TO "$DB_USER";
ALTER DEFAULT PRIVILEGES IN SCHEMA $SCHEMA GRANT SELECT ON TABLES TO "$DB_USER";
EOM

function error_exit {
  echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

if [[ $1 = "--create-db-user" ]]; then
  # If $DB_USER is missing, create them. Run as db super user
  if ! psql -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
    createuser || error_exit "$LINENO: Failed to create user $DB_USER";
  fi
  echo "Done!";
  exit 1;
fi

if [[ $1 = "--create-db" ]]; then
  # If DB missing, then create db, scheam and table.
  if [[ -z `psql -Atqc "\list $DB"` ]]; then
    createdb $DB || error_exit "$LINENO: Failed to create db $DB";
    echo "$DB db created";
    psql -d $DB -Atqc "$SQL" || error_exit "$LINENO: Failed to create db $SCHEMA and $TABLE";
    echo "$SCHEMA.$TABLE created";
  fi
  echo "Done!";
  exit 1;
fi

# Run afterwards to index all the things.
if [[ $1 = "--index" ]]; then
  echo "Creating spatial index on $GEO_COLUMN_NAME column in $SCHEMA.$TABLE, I may be some time";
  psql -d $DB -c "CREATE INDEX $TABLE_gix ON $SCHEMA.$TABLE USING GIST ($GEO_COLUMN_NAME);";
  psql -d $DB -c "VACUUM ANALYZE $SCHEMA.$TABLE;";
  echo "Done!";
  exit 1;
fi

if [[ ! -f $ZIP ]]; then
  echo "Downloading $ZIP";
  wget -q http://data.inspire.landregistry.gov.uk/$ZIP || error_exit "$LINENO: Failed to download $ZIP";
fi

if [[ ! -f $NAME.gml ]]; then
  # HACK: ogr2ogr tries and fails to download the schema for the gml file. `sed` is used to strip the reference.
  # See: https://github.com/psd/landregistry-inspire-data/blob/1c239d0299d8b8c72bf48b854ce03155213b3281/Makefile#L21
  unzip -p -a $ZIP Land_Registry_Cadastral_Parcels.gml | sed -e 's/xsi:schemaLocation="[^"]*"//' > $NAME.gml
fi

if [[ ! -f $NAME.gml ]]; then
  error_exit "$LINENO: $NAME.gml missing. Failed to extract Land_Registry_Cadastral_Parcels.gml from $ZIP";
fi

# if sqldump missing, create it now.
if [[ ! -f $NAME.sql ]]; then
  echo "Converting $NAME.gml to SQL";
  ogr2ogr \
    --config PG_USE_COPY YES \
    -lco create_schema=off \
    -lco create_table=off \
    -lco spatial_index=off \
    -lco schema=$SCHEMA \
    -lco geom_type=$GEO_COLUMN_TYPE \
    -lco geometry_name=$GEO_COLUMN_NAME \
    -s_srs $SOURCE_SRS \
    -t_srs $TARGET_SRS \
    -select inspireid \
    -nln $TABLE \
    -f PGDump $NAME.sql \
    $NAME.gml \
    -progress || error_exit "$LINENO: Failed to convert $NAME.gml to SQL";
fi

echo "Importing $NAME.sql to $DB db"

if psql -d $DB -f $NAME.sql -v ON_ERROR_STOP=1 ; then
  # Clean up.
  rm $NAME.sql $NAME.gml $NAME.gfs $NAME.zip
  echo "Success! $NAME.sql imported";
else
  error_exit "$LINENO: Failed to import $NAME.sql to $DB";
fi
