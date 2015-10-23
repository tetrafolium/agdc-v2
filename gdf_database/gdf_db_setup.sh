#!/bin/bash
# Script to setup an empty GDF database on a freshly installed local PostGIS database

set -eu

echo_bold() { printf "\e[31m${@}\e[0m\n"; }
echo_error() { >&2 echo "$@"; }

if [ $# -ne 2 ]
then
  echo_error "Usage: $0 <hostname> <db_name>"
  echo_error "   eg: $0 localhost gdf"
  exit 1
fi

db_host=${1}
db_name=${2}

psql="psql -q -h ${db_host}"

# Create default GDF groups and users (ignore failures: they may already exist)
${psql} -d postgres -e -c "
CREATE ROLE cube_admin_group
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

CREATE ROLE cube_user_group
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
" || true

# Create new database ${dbname}
${psql} -e -d postgres -c "
CREATE DATABASE ${db_name}
  WITH OWNER = cube_admin_group
       TEMPLATE = template0
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;"

${psql} -e -d ${db_name} -c "
ALTER DATABASE ${db_name}
  SET search_path = "\"$USER\"", public, topology;"

# Install required extensions to database
${psql} -e -d ${db_name} -f extensions.sql

echo
# Apply each change in order. 
# TODO: Temporary solution: it doesn't hanlde multi-digit version numbers.
#       We will probably use a tool like Flyway for real deployments.
for f in ./versioned/v*.sql;
do
    echo -n "Running ${f}..."
    ${psql} -d ${db_name} -v ON_ERROR_STOP=1 --single-transaction <<EOF
    set role to cube_admin_group;
    \\i ${f}
EOF
    echo_bold 'done'
done
echo

${psql} -e -d ${db_name} -f grants.sql

echo
echo_bold "Created successfully."
echo
echo "Now add users to the groups 'cube_admin_group' and 'cube_user_group' as needed."
echo "    eg. "
echo "        psql -h ${db_host} -c 'grant cube_admin_group to jmh547'"
echo "        psql -h ${db_host} -c 'grant cube_user_group to rtw547'"
