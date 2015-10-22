#!/bin/bash
# Script to setup an empty GDF database on a freshly installed local PostGIS database

dbname=gdf_empty

# Create default GDF groups and users
psql -U postgres -c "
CREATE ROLE cube_admin_group
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

CREATE ROLE cube_user_group
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

CREATE ROLE cube_admin LOGIN
  ENCRYPTED PASSWORD 'md5bef0c3c7aadc8744bc3fa174c5e80f6b'
  SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
GRANT cube_admin_group TO cube_admin;
GRANT cube_user_group TO cube_admin;

CREATE ROLE cube_user LOGIN
  ENCRYPTED PASSWORD 'md57c93896ee15147e58d639d52196e092a'
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT cube_user_group TO cube_user;
"

# Create new database ${dbname}
psql -d postgres -c "
CREATE DATABASE ${dbname}
  WITH OWNER = cube_admin
       TEMPLATE = template0
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;"

psql -d ${dbname} -c "
ALTER DATABASE ${dbname}
  SET search_path = "\"$USER\"", public, topology;"

# Install required extensions to database
psql -d ${dbname} -f extensions.sql

# Change user for ownership of the created schema.
export PGUSER=cube_admin
export PGPASSWORD='GAcube!'
export PGHOST=localhost

# Apply each change in order. 
# TODO: Temporary solution: it doesn't hanlde multi-digit version numbers.
#       We will probably use a tool like Flyway for real deployments.
for f in ./versioned/v*.sql;
do
    psql -d ${dbname} -v ON_ERROR_STOP=1 --single-transaction -f "${f}"
done

psql -d ${dbname} -f grants.sql

