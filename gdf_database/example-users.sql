
CREATE ROLE cube_admin LOGIN
  PASSWORD 'cube_admin'
  SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
GRANT cube_admin_group TO cube_admin;
GRANT cube_user_group TO cube_admin;

CREATE ROLE cube_user LOGIN
  PASSWORD 'cube_user'
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT cube_user_group TO cube_user;
