
create extension if not exists plpgsql with schema pg_catalog;

create extension if not exists postgis;

create schema if not exists topology;
create extension if not exists postgis_topology with schema topology;
