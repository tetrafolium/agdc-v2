#!/bin/bash
# Script to setup an empty GDF database on a freshly installed local PostGIS database

set -eu

dbname=gdf_empty
admin_user=cube_admin

psql='psql -q'

# Create default GDF groups and users (ignore failures: they may already exist)
${psql} -d postgres -e -c "
CREATE ROLE cube_admin_group
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

CREATE ROLE cube_user_group
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT cube_admin_group TO ${admin_user};
" || true


# Create new database ${dbname}
${psql} -e -d postgres -c "
CREATE DATABASE ${dbname}
  WITH OWNER = cube_admin_group
       TEMPLATE = template0
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;"

${psql} -e -d ${dbname} -c "
ALTER DATABASE ${dbname}
  SET search_path = "\"$USER\"", public, topology;"

# Install required extensions to database
${psql} -e -d ${dbname} -f extensions.sql

echo
# Apply each change in order. 
# TODO: Temporary solution: it doesn't hanlde multi-digit version numbers.
#       We will probably use a tool like Flyway for real deployments.
for f in ./versioned/v*.sql;
do
    echo -n "Running ${f}..."
    ${psql} -d ${dbname} -v ON_ERROR_STOP=1 --single-transaction <<EOF
    set role to cube_admin_group;
    \\i ${f}
EOF
    echo 'done'
done
echo

${psql} -e -d ${dbname} -f grants.sql

