#
# Import INSPIRE index polygons into postgres
#
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

ZIP=$1
NAME=${ZIP%.zip}
DB="landexplorer"
SCHEMA="landregistry"
TABLE="inspire"
GEO_COLUMN_TYPE="geography"
GEO_COLUMN_NAME="boundary"
SOURCE_SRS="EPSG:27700"
TARGET_SRS="EPSG:4326"
SOURCE_FILE="Land_Registry_Cadastral_Parcels.gml"
DUMP_FILE="inspire.sql"

# SQL to init postgis, schema and table
read -r -d '' SQL << EOM
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SCHEMA IF NOT EXISTS $SCHEMA;
CREATE TABLE IF NOT EXISTS $SCHEMA.$TABLE (
  id serial PRIMARY KEY,
  $GEO_COLUMN_NAME geography(Polygon,4326) NOT NULL,
  inspireid integer NOT NULL
)
EOM

if [[ $ZIP = "index" ]];
  then
    psql -d $DB -c "CREATE INDEX $TABLE_gix ON $SCHEMA.$TABLE USING GIST ($GEO_COLUMN_NAME);";
    psql -d $DB -c "VACUUM ANALYZE $SCHEMA.$TABLE;";
    psql -d $DB -c "EXPLAIN ANALYZE SELECT inspireid from landregistry.inspire i WHERE ST_Covers(i.boundary, ST_GeographyFromText('POINT(-5.57990 50.18967)'));"
    psql -d $DB -c "SELECT count(*) from landregistry.inspire"
    exit 1;
fi

if [[ ! -d $NAME ]];
  then
    mkdir $NAME;
    # HACK: ogr2ogr tries and fails to download the schema for the gml file. `sed` is used to strip the reference.
    # See: https://github.com/psd/landregistry-inspire-data/blob/1c239d0299d8b8c72bf48b854ce03155213b3281/Makefile#L21
    unzip -p -a $ZIP Land_Registry_Cadastral_Parcels.gml | sed -e 's/xsi:schemaLocation="[^"]*"//' > $NAME/Land_Registry_Cadastral_Parcels.gml
fi

cd $NAME;

# if sqldump missing, create it now.
if [[ ! -f $DUMP_FILE ]];
  then
    echo "Convering GML to SQL";
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
      -f PGDump $DUMP_FILE \
      $SOURCE_FILE \
      -progress;
fi

# If DB missing, then create all the things.
if [[ -z `psql -Atqc "\list $DB"` ]];
  then
    createdb $DB;
    echo "$DB db created";
    psql -d $DB -Atqc "$SQL";
    echo "$SCHEMA.$TABLE created";
fi

psql -d $DB -f $DUMP_FILE
echo "$NAME imported";
