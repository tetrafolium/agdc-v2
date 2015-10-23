#!/bin/bash
# Script to restore a backup to a database on a PostGIS database server


echo_error() { >&2 echo "$@"; }

if [ $# -ne 3 ]
then
  echo_error "Usage: $0 <hostname> <db_name> <db_backup_file>"
  exit 1
fi

db_host=$1
dbname=$2
db_backup_file=$3

export PGHOST=${db_host}

# Create new database ${dbname}
psql -d postgres -c "
CREATE DATABASE ${dbname}
  WITH OWNER = cube_admin_group
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;"

psql -d ${dbname} -c "
ALTER DATABASE ${dbname}
  SET search_path = "\"$USER\"",public, topology;

COMMENT ON DATABASE ${dbname}
  IS 'GDF Database restored from ${db_backup_file} $(date)';"


# Install required extensions to database
psql -d ${dbname} -f extensions.sql

# Restore DB from backup
pg_restore -d ${dbname} ${db_backup_file}

psql -d ${dbname} -c "vacuum analyze"
