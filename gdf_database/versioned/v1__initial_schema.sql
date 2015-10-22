

create table datatype (
  datatype_id          smallint not null,
  datatype_name        character varying(16),
  numpy_datatype_name  character varying(16),
  gdal_datatype_name   character varying(16),
  netcdf_datatype_name character varying(16)
);
comment on table datatype is 'Configuration: Lookup table for measurement_type datatypes.';
comment on column datatype.datatype_id is 'Primary key for datatype';
comment on column datatype.datatype_name is 'Long name of datatype';
comment on column datatype.numpy_datatype_name is 'Text representation of numpy datatype';
comment on column datatype.gdal_datatype_name is 'Text representation of GDAL datatype';
comment on column datatype.netcdf_datatype_name is 'Text representation of netCDF datatype';

alter table only datatype
add constraint pk_datatype primary key (datatype_id);

alter table only datatype
add constraint uq_datatype_datatype_name unique (datatype_name);


create table indexing_type (
  indexing_type_id   smallint not null,
  indexing_type_name character varying(128)
);
comment on table indexing_type is 'Configuration: Lookup table to manage what kind of indexing to apply to a given dimension';
comment on column indexing_type.indexing_type_id is 'Primary key for indexing_type';
comment on column indexing_type.indexing_type_name is 'Name of indexing type.
Types include regular (e.g. lat/lon), irregular (e.g. time) and fixed (e.g. bands)';

alter table only indexing_type
add constraint pk_indexing_type primary key (indexing_type_id);

alter table only indexing_type
add constraint uq_indexing_type_indexing_type_name unique (indexing_type_name);


create table measurement_metatype (
  measurement_metatype_id   bigint not null,
  measurement_metatype_name character varying(254)
);
comment on table measurement_metatype is 'Configuration: Lookup table for general type of measurement (e.g. spectral band)';
comment on column measurement_metatype.measurement_metatype_id is 'Primary key for measurement_metatype';
comment on column measurement_metatype.measurement_metatype_name is 'Name of measurement metatype.';

alter table only measurement_metatype
add constraint pk_measurement_metatype primary key (measurement_metatype_id);

alter table only measurement_metatype
add constraint uq_measurement_metatype_measurement_metatype_name unique (measurement_metatype_name);


create table measurement_type (
  measurement_metatype_id bigint                not null,
  measurement_type_id     bigint                not null,
  measurement_type_name   character varying(50) not null,
  measurement_type_tag    character varying(16)
);
comment on table measurement_type is 'Configuration: Description of measurement(s) held in n-dimensional data structures: e.g. bands';
comment on column measurement_type.measurement_metatype_id is 'Part of compound primary key for measurement_type (other key is measurement_type_id). Foreign key to measurement_metatype.';
comment on column measurement_type.measurement_type_id is 'Part of compound primary key for measurement_type (other key is measurement_metatype_id).';
comment on column measurement_type.measurement_type_name is 'Long name of measurement type';
comment on column measurement_type.measurement_type_tag is 'Short tag (candidate_key) for measurement_type';

alter table only measurement_type
add constraint pk_measurement_type primary key (measurement_metatype_id, measurement_type_id);

create index fki_measurement_type_measurement_metatype on measurement_type using btree (measurement_metatype_id);

alter table only measurement_type
add constraint fk_measurement_type_measurement_metatype foreign key (measurement_metatype_id) references measurement_metatype (measurement_metatype_id);


create table property (
  property_id   bigint not null,
  property_name character varying(32),
  datatype_id   smallint
);
comment on table property is 'Configuration: Lookup table for properties which can have an associated value in metadata.';
comment on column property.property_id is 'Primary key for property';
comment on column property.property_name is 'Name of property';
comment on column property.datatype_id is 'Foreign key to datatype';

alter table only property
add constraint property_pkey primary key (property_id);

alter table only property
add constraint uq_property_property_name unique (property_name);


create table reference_system (
  reference_system_id         bigint not null,
  reference_system_name       character varying(32),
  reference_system_unit       character varying(32),
  reference_system_definition character varying(254),
  reference_system_tag        character varying(32)
);
comment on table reference_system is 'Configuration: Coordinate reference systems for aplication to specific domains.
e.g. EPSG:4326, seconds since 1/1/1970 0:00, etc.';
comment on column reference_system.reference_system_id is 'Primary key for reference_system';
comment on column reference_system.reference_system_name is 'Long name for reference_system';
comment on column reference_system.reference_system_unit is 'Unit for reference_system';
comment on column reference_system.reference_system_definition is 'Textual definition of reference system.';
comment on column reference_system.reference_system_tag is 'Short tag (candidate_key) for reference_system.';

alter table only reference_system
add constraint pk_reference_system primary key (reference_system_id);

alter table only reference_system
add constraint uq_reference_system_reference_system_name unique (reference_system_name);


create table reference_system_indexing (
  reference_system_id     bigint  not null,
  array_index             integer not null,
  indexing_name           character varying(64),
  measurement_metatype_id bigint,
  measurement_type_id     bigint
);
comment on table reference_system_indexing is 'Configuration: Optional non-linear indexing for dimension in a given domain.
e.g. A spectral dimension containing multple bands needs to be indexed by band number, and each band number can be associated with a given measurement_type.';
comment on column reference_system_indexing.reference_system_id is 'Part of composite primary key for reference_system_indexing (other key is array_index). Foreign key to reference_system.';
comment on column reference_system_indexing.array_index is 'Part of composite primary key for reference_system_indexing (other key is reference_system_id). Zero-based array index for array dimension (e.g. spectral band).';
comment on column reference_system_indexing.indexing_name is 'NFI - what was I thinking?';
comment on column reference_system_indexing.measurement_metatype_id is 'Part of foreign key to measurement_type (other key is measurement_type_id). Also indirect reference to measurement_metatype.';
comment on column reference_system_indexing.measurement_type_id is 'Part of foreign key to measurement_type (other key is measurement_metatype_id).';

alter table only reference_system_indexing
add constraint pk_reference_system_indexing primary key (reference_system_id, array_index);

create index fki_reference_system_indexing_measurement_type on reference_system_indexing using btree (measurement_metatype_id, measurement_type_id);

create index fki_reference_system_indexing_reference_system on reference_system_indexing using btree (reference_system_id);

alter table only reference_system_indexing
add constraint fk_reference_system_indexing_measurement_type foreign key (measurement_metatype_id, measurement_type_id) references measurement_type (measurement_metatype_id, measurement_type_id);

alter table only reference_system_indexing
add constraint fk_reference_system_indexing_reference_system foreign key (reference_system_id) references reference_system (reference_system_id);


create table spatial_footprint (
  spatial_footprint_id       bigint   not null,
  spatial_footprint_geometry geometry not null
);
comment on table spatial_footprint is 'Data: Spatial footprint associated with storage units.';
comment on column spatial_footprint.spatial_footprint_id is 'Primary key for spatial footprint';
comment on column spatial_footprint.spatial_footprint_geometry is 'PostGIS geometry for storage unit footprint';

alter table only spatial_footprint
add constraint pk_spatial_footprint primary key (spatial_footprint_id);


create table platform_type (
  platform_type_id   bigint not null,
  platform_type_name character varying(128)
);
comment on table platform_type is 'Configuration: Lookup table for platform category
e.g. Satellite or Ship';
comment on column platform_type.platform_type_id is 'Primary key for platform_type';
comment on column platform_type.platform_type_name is 'Name of platform_type';

alter table only platform_type
add constraint pk_platform_type primary key (platform_type_id);

alter table only platform_type
add constraint uq_platform_type_platform_type_name unique (platform_type_name);


create table platform (
  platform_type_id bigint not null,
  platform_id      bigint not null,
  platform_name    character varying(128),
  platform_tag     character varying(16)
);
comment on table platform is 'Configuration: Platform on which instrument is mounted.
An example would be a specific satellite such as Landsat 7';
comment on column platform.platform_type_id is 'Part of composite primary key for platform (other key is platform_id). Also indirect reference to platform_type.';
comment on column platform.platform_id is 'Part of composite primary key for platform (other key is platform_type_id). ';
comment on column platform.platform_name is 'Long name for platform';
comment on column platform.platform_tag is 'Short tag (candidate key) for platform';

alter table only platform
add constraint pk_platform primary key (platform_type_id, platform_id);

alter table only platform
add constraint uq_platform_platform_name unique (platform_name);

alter table only platform
add constraint uq_platform_platform_tag unique (platform_tag);

create index fki_platform_platform_type on platform using btree (platform_type_id);

alter table only platform
add constraint fk_platform_platform_type foreign key (platform_type_id) references platform_type (platform_type_id);


create table instrument_type (
  instrument_type_id   bigint not null,
  instrument_type_name character varying(128)
);
comment on table instrument_type is 'Configuration: Lookup table for instrument category';
comment on column instrument_type.instrument_type_id is 'Primary key for instrument_type.';
comment on column instrument_type.instrument_type_name is 'Name of instrument_type.';

alter table only instrument_type
add constraint pk_instrument_type primary key (instrument_type_id);

alter table only instrument_type
add constraint uq_instrument_type_instrument_type_name unique (instrument_type_name);


create table instrument (
  instrument_type_id bigint not null,
  instrument_id      bigint not null,
  instrument_name    character varying(128),
  platform_type_id   bigint,
  platform_id        bigint,
  instrument_tag     character varying(32)
);
comment on table instrument is 'Configuration: Instrument used to gather observations.
An example would be the ETM+ sensor on the Landsat 7 platform';
comment on column instrument.instrument_type_id is 'Part of compound primary key for instrument (other key is instrument_id). Foreign key to instrument_type';
comment on column instrument.instrument_id is 'Part of compound primary key for instrument (other key is instrument_type_id).';
comment on column instrument.instrument_name is 'Name of instrument';
comment on column instrument.platform_type_id is 'Partial foreign key to platform (other key is platform_id). Also indirect reference to platform_type.';
comment on column instrument.platform_id is 'Partial foreign key to platform (other key is platform_type_id).';
comment on column instrument.instrument_tag is 'Short tag (candidate key) for instrument.';

alter table only instrument
add constraint pk_instrument primary key (instrument_type_id, instrument_id);

alter table only instrument
add constraint uq_instrument_instrument_name unique (instrument_name);

alter table only instrument
add constraint uq_instrument_instrument_tag unique (instrument_tag);

create index fki_instrument_instrument_type on instrument using btree (instrument_type_id);

create index fki_instrument_platform on instrument using btree (platform_type_id, platform_id);

alter table only instrument
add constraint fk_instrument_instrument_type foreign key (instrument_type_id) references instrument_type (instrument_type_id) on update cascade on delete cascade;

alter table only instrument
add constraint fk_instrument_platform foreign key (platform_type_id, platform_id) references platform (platform_type_id, platform_id) on update cascade on delete cascade;


create table observation_type (
  observation_type_id   bigint not null,
  observation_type_name character varying(254)
);
comment on table observation_type is 'Configuration: Lookup table for type of source observation';
comment on column observation_type.observation_type_id is 'Primary key for observation type';
comment on column observation_type.observation_type_name is 'Long name for observation type';

alter table only observation_type
add constraint pk_observation_type primary key (observation_type_id);

alter table only observation_type
add constraint uq_observation_type_observation_type_name unique (observation_type_name);


create table observation (
  observation_type_id        bigint not null,
  observation_id             bigint not null,
  observation_start_datetime timestamp with time zone,
  observation_end_datetime   timestamp with time zone,
  instrument_type_id         bigint,
  instrument_id              bigint,
  observation_reference      character varying(128)
);
comment on table observation is 'Data: Source observation for datasets.
Analagous to old "acquisition" table in AGDC version 0 DB';
comment on column observation.observation_type_id is 'Part of compound primary key for observation (other key is observation_id). Foreign key to observation_type.';
comment on column observation.observation_id is 'Part of compound primary key for observation (other key is observation_type_id).';
comment on column observation.observation_start_datetime is 'Start datetime for observation.';
comment on column observation.observation_end_datetime is 'End datetime for observation.';
comment on column observation.instrument_type_id is 'Part of foreign key to instrument (other key is instrument_id). Also indirect reference to instrument_type.';
comment on column observation.instrument_id is 'Part of foreign key to instrument (other key is instrument_type_id).';
comment on column observation.observation_reference is 'Unique reference for observation (e.g. Landsat Path-Row-Date)';

alter table only observation
add constraint pk_observation primary key (observation_type_id, observation_id);

create index fki_observation_instrument on observation using btree (instrument_type_id, instrument_id);

create index fki_observation_observation_type on observation using btree (observation_type_id);

create unique index idx_observation_reference on observation using btree (observation_reference);

alter table only observation
add constraint fk_observation_instrument foreign key (instrument_type_id, instrument_id) references instrument (instrument_type_id, instrument_id);

alter table only observation
add constraint fk_observation_observation_type foreign key (observation_type_id) references observation_type (observation_type_id) on update cascade on delete cascade;

create sequence observation_id_seq
start with 100
increment by 1
no minvalue
no maxvalue
cache 1;


create table dataset_type (
  dataset_type_id   bigint not null,
  dataset_type_name character varying(254),
  dataset_type_tag  character varying(32)
);
comment on table dataset_type is 'Configuration: Type of source dataset (processing level)';
comment on column dataset_type.dataset_type_id is 'Primary key for dataset_type.';
comment on column dataset_type.dataset_type_name is 'Long name for dataset type.';
comment on column dataset_type.dataset_type_tag is 'Short tag (candidate key) for dataset_type';

alter table only dataset_type
add constraint pk_dataset_type primary key (dataset_type_id);

alter table only dataset_type
add constraint uq_dataset_type_dataset_type_name unique (dataset_type_name);

alter table only dataset_type
add constraint uq_dataset_type_dataset_type_tag unique (dataset_type_tag);


create table dataset (
  dataset_type_id      bigint not null,
  dataset_id           bigint not null,
  observation_type_id  bigint not null,
  observation_id       bigint not null,
  dataset_location     character varying(254),
  creation_datetime    timestamp with time zone,
  dataset_bytes        bigint,
  dataset_md5_checksum character(32)
);
comment on table dataset is 'Data: Source dataset (file) ingested.
An example would be a dataset for a particular NBAR Landsat scene.';
comment on column dataset.dataset_type_id is 'Foreign key to dataset_type. Part of composite primary key for dataset record (other key is dataset_id).';
comment on column dataset.dataset_id is 'Part of composite primary key for dataset. Other key is dataset_type_id.';
comment on column dataset.observation_type_id is 'Part of composite foreign key to observation (other key is observation_id). Also indirect reference to observation_type.';
comment on column dataset.observation_id is 'Part of composite foreign key to observation (other key is observation_type_id).';
comment on column dataset.dataset_location is 'Fully qualified path to source dataset file';
comment on column dataset.creation_datetime is 'Timestamp for source dataset creation (read from metadata)';
comment on column dataset.dataset_bytes is 'Number of bytes in source dataset file';
comment on column dataset.dataset_md5_checksum is 'MD5 checksum for source dataset file';

alter table only dataset
add constraint pk_dataset primary key (dataset_type_id, dataset_id);

create index fki_dataset_dataset_type on dataset using btree (dataset_type_id);

create index fki_dataset_observation on dataset using btree (observation_type_id, observation_id);

alter table only dataset
add constraint fk_dataset_dataset_type foreign key (dataset_type_id) references dataset_type (dataset_type_id) on update cascade on delete cascade;

alter table only dataset
add constraint fk_dataset_observation foreign key (observation_type_id, observation_id) references observation (observation_type_id, observation_id) on update cascade on delete cascade;

create sequence dataset_id_seq
start with 100
increment by 1
no minvalue
no maxvalue
cache 1;


create table domain (
  domain_id   bigint not null,
  domain_name character varying(16),
  domain_tag  character varying(16)
);
comment on table domain is 'Configuration: Domain groupings of dimensions (e.g. spectral, spatial XY, spatial XYZ, temporal)';
comment on column domain.domain_id is 'Primary key for domain';
comment on column domain.domain_name is 'Long name for domain';
comment on column domain.domain_tag is 'Short tag (candidate key) for domain.';

alter table only domain
add constraint pk_domain primary key (domain_id);

alter table only domain
add constraint uq_domain_domain_name unique (domain_name);

alter table only domain
add constraint uq_domain_domain_tag unique (domain_tag);


create table dimension (
  dimension_id   bigint                not null,
  dimension_name character varying(50) not null,
  dimension_tag  character varying(8)  not null
);
comment on table dimension is 'Configuration: Dimensions for n-dimensional data structures, e.g. x,y,z,t';
comment on column dimension.dimension_id is 'Primary key for dimension';
comment on column dimension.dimension_name is 'Long name for dimension';
comment on column dimension.dimension_tag is 'Short tag (candidate key) for dimension.';

alter table only dimension
add constraint pk_dimension primary key (dimension_id);

alter table only dimension
add constraint uq_dimension_dimension_name unique (dimension_name);

alter table only dimension
add constraint uq_dimension_dimension_tag unique (dimension_tag);


create table dimension_domain (
  domain_id    bigint not null,
  dimension_id bigint not null
);
comment on table dimension_domain is 'Configuration: Many-many  mapping between dimensions and domains to allow multiple dimensions to be included in multiple domains.
For example, the z dimension could be managed in a Z-spatial domain, or in an XYZ-spatial domain.';
comment on column dimension_domain.domain_id is 'Foreign key to domain';
comment on column dimension_domain.dimension_id is 'Foreign key to dimension.';

alter table only dimension_domain
add constraint pk_dimension_domain primary key (domain_id, dimension_id);

create index fki_dimension_domain_dimension on dimension_domain using btree (dimension_id);

create index fki_dimension_domain_domain on dimension_domain using btree (domain_id);

alter table only dimension_domain
add constraint fk_dimension_domain_dimension foreign key (dimension_id) references dimension (dimension_id) on update cascade on delete cascade;

alter table only dimension_domain
add constraint fk_dimension_domain_domain foreign key (domain_id) references domain (domain_id) on update cascade on delete cascade;


create table dataset_type_domain (
  dataset_type_id     bigint not null,
  domain_id           bigint not null,
  reference_system_id bigint
);
comment on table dataset_type_domain is 'Configuration: Association between dataset types and domains (many-many).
Used to define which domains cover a given dataset type';
comment on column dataset_type_domain.dataset_type_id is 'Part of composite primary key (other key is domain_id). Foreign key to dataset_type.';
comment on column dataset_type_domain.domain_id is 'Part of composite primary key (other key is dataset_type_id). Foreign key to domain.';
comment on column dataset_type_domain.reference_system_id is 'Foreign key to reference_system';

alter table only dataset_type_domain
add constraint pk_dataset_type_domain primary key (dataset_type_id, domain_id);

create index fki_dataset_type_domain_dataset_type on dataset_type_domain using btree (dataset_type_id);

create index fki_dataset_type_domain_domain on dataset_type_domain using btree (domain_id);

create index fki_dataset_type_domain_reference_system on dataset_type_domain using btree (reference_system_id);

alter table only dataset_type_domain
add constraint fk_dataset_type_domain_dataset_type foreign key (dataset_type_id) references dataset_type (dataset_type_id) on update cascade on delete cascade;

alter table only dataset_type_domain
add constraint fk_dataset_type_domain_domain foreign key (domain_id) references domain (domain_id) on update cascade on delete cascade;

alter table only dataset_type_domain
add constraint fk_dataset_type_domain_reference_system foreign key (reference_system_id) references reference_system (reference_system_id) on update cascade on delete cascade;


create table dataset_type_dimension (
  dataset_type_id bigint                not null,
  domain_id       bigint                not null,
  dimension_id    bigint                not null,
  dimension_order smallint              not null,
  reverse_index   boolean default false not null
);
comment on table dataset_type_dimension is 'Configuration: Association between dataset type and dimensions. Used to define dimensionality of source dataset types';
comment on column dataset_type_dimension.dataset_type_id is 'Part of composite primary key (other keys are domain_id and dimension_id). Foreign key to dataset_type.';
comment on column dataset_type_dimension.domain_id is 'Part of composite primary key (other keys are dataset_type_id and dimension_id). Foreign key to domain';
comment on column dataset_type_dimension.dimension_id is 'Part of composite primary key (other keys are dataset_type_id and domain_id). Foreign key to dimension.';
comment on column dataset_type_dimension.dimension_order is 'Order in which dimensions are arranged in each dataset_type';
comment on column dataset_type_dimension.reverse_index is 'Boolean flag indicating whether sense of indexing is reversed (e.g. Y axis for imagery)';

alter table only dataset_type_dimension
add constraint pk_dataset_type_dimension primary key (dataset_type_id, domain_id, dimension_id);

alter table only dataset_type_dimension
add constraint uq_dataset_type_dimension_dataset_type_id_dimension_order unique (dataset_type_id, dimension_order);

create index fki_dataset_type_dimension_dataset_type_domain on dataset_type_dimension using btree (dataset_type_id, domain_id);

create index fki_dataset_type_dimension_dimension_domain on dataset_type_dimension using btree (domain_id, dimension_id);

alter table only dataset_type_dimension
add constraint fk_dataset_type_dimension_dataset_type_domain foreign key (dataset_type_id, domain_id) references dataset_type_domain (dataset_type_id, domain_id) on update cascade on delete cascade;

alter table only dataset_type_dimension
add constraint fk_dataset_type_dimension_dimension_domain foreign key (domain_id, dimension_id) references dimension_domain (domain_id, dimension_id) on update cascade on delete cascade;


create table dataset_dimension (
  dataset_type_id bigint           not null,
  dataset_id      bigint           not null,
  domain_id       bigint           not null,
  dimension_id    bigint           not null,
  min_value       double precision not null,
  max_value       double precision not null,
  indexing_value  double precision
);
comment on table dataset_dimension is 'Data: Dimensional parameters for each source dataset.
Each dataset/dimension will have specific max/min/indexing values showing the range covered by the dataset in that particular dimension.';
comment on column dataset_dimension.dataset_type_id is 'Part of composite foreign key to dataset (other key is dataset_id). Also indirect reference to dataset_type';
comment on column dataset_dimension.dataset_id is 'Part of composite foreign key to dataset (other key is dataset_type_id).';
comment on column dataset_dimension.domain_id is 'Part of composite foreign key to dataset_type_dimension (other key is dimension_id). Also indirect reference to domain.';
comment on column dataset_dimension.dimension_id is 'Part of composite foreign key to dataset_type_dimension (other key is domain_id). Also indirect reference to dimension.';
comment on column dataset_dimension.min_value is 'Minimum value in specified dimension for source dataset.';
comment on column dataset_dimension.max_value is 'Maximum value in specified dimension for source dataset.';
comment on column dataset_dimension.indexing_value is 'Value used for indexing in specified dimension for source dataset. Only set for irregular dimensions (e.g. time for EO data).';

alter table only dataset_dimension
add constraint pk_dataset_dimension primary key (dataset_type_id, dataset_id, domain_id, dimension_id);

create index fki_dataset_dimension_dataset on dataset_dimension using btree (dataset_type_id, dataset_id);

create index fki_dataset_dimension_dataset_type_dimension on dataset_dimension using btree (dataset_type_id, domain_id, dimension_id);

alter table only dataset_dimension
add constraint fk_dataset_dimension_dataset foreign key (dataset_type_id, dataset_id) references dataset (dataset_type_id, dataset_id) on update cascade on delete cascade;

alter table only dataset_dimension
add constraint fk_dataset_dimension_dataset_type_dimension foreign key (dataset_type_id, domain_id, dimension_id) references dataset_type_dimension (dataset_type_id, domain_id, dimension_id) on update cascade on delete cascade;


create table dataset_metadata (
  dataset_type_id bigint not null,
  dataset_id      bigint not null,
  metadata_xml    xml    not null
);
comment on table dataset_metadata is 'Data: Lookup table for dataset-level metadata (one:one)';
comment on column dataset_metadata.dataset_type_id is 'Part of composite foreign key to dataset (other key is dataset_id). Also indirect reference to dataset_type';
comment on column dataset_metadata.dataset_id is 'Part of composite foreign key to dataset (other key is dataset_type_id).';
comment on column dataset_metadata.metadata_xml is 'XML metadata harvested from source dataset';

alter table only dataset_metadata
add constraint pk_dataset_metadata primary key (dataset_type_id, dataset_id);

create index fki_dataset_metadata_dataset on dataset_metadata using btree (dataset_type_id, dataset_id);

alter table only dataset_metadata
add constraint fk_dataset_metadata_dataset foreign key (dataset_type_id, dataset_id) references dataset (dataset_type_id, dataset_id) on update cascade on delete cascade;


create table dataset_type_measurement_type (
  dataset_type_id         bigint not null,
  measurement_metatype_id bigint not null,
  measurement_type_id     bigint not null,
  datatype_id             smallint,
  measurement_type_index  smallint
);
comment on table dataset_type_measurement_type is 'Configuration: Associations between dataset types and measurement types (one-many)
e.g. associations between Landsat 7 NBAR and specific surface-reflectance corrected Landsat 7 bands';
comment on column dataset_type_measurement_type.dataset_type_id is 'Part of composite primary key (other keys are measurement_metatype_id and measurement_type_id). Foreign key to dataset_type.';
comment on column dataset_type_measurement_type.measurement_metatype_id is 'Part of composite primary key (other keys are dataset_type_id and measurement_type_id).  Part of composite foreign key to measurement_type. Indirect reference to measurement_metatype.';
comment on column dataset_type_measurement_type.measurement_type_id is 'Part of composite primary key (other keys are dataset_type_id and measurement_type_id). Part of composite foreign key to measurement_type.';
comment on column dataset_type_measurement_type.datatype_id is 'Foreign key to datatype.';
comment on column dataset_type_measurement_type.measurement_type_index is 'Order in which measurement type is stored in source dataset file';

alter table only dataset_type_measurement_type
add constraint pk_dataset_type_measurement_type primary key (dataset_type_id, measurement_metatype_id, measurement_type_id);

alter table only dataset_type_measurement_type
add constraint uq_dataset_type_measurement_type_dataset_type unique (dataset_type_id, measurement_type_index);

create index fki_dataset_type_measurement_metatype_datatype on dataset_type_measurement_type using btree (datatype_id);

create index fki_dataset_type_measurement_type_dataset_type on dataset_type_measurement_type using btree (dataset_type_id);

create index fki_dataset_type_measurement_type_measurement_type on dataset_type_measurement_type using btree (measurement_metatype_id, measurement_type_id);

alter table only dataset_type_measurement_type
add constraint fk_dataset_type_measurement_type_dataset_type foreign key (dataset_type_id) references dataset_type (dataset_type_id) on update cascade on delete cascade;

alter table only dataset_type_measurement_type
add constraint fk_dataset_type_measurement_type_datatype foreign key (datatype_id) references datatype (datatype_id) on update cascade on delete cascade;

alter table only dataset_type_measurement_type
add constraint fk_dataset_type_measurement_type_measurement_type foreign key (measurement_metatype_id, measurement_type_id) references measurement_type (measurement_metatype_id, measurement_type_id) on update cascade on delete cascade;


create table storage_type (
  storage_type_id       bigint                 not null,
  storage_type_name     character varying(254),
  storage_type_tag      character varying(16),
  storage_type_location character varying(256) not null
);
comment on table storage_type is 'Configuration: storage parameter lookup table. Used TO manage different storage_types';
comment on column storage_type.storage_type_id is 'Primary key for storage_type.';
comment on column storage_type.storage_type_name is 'Long name for storage_type.';
comment on column storage_type.storage_type_tag is 'Short tag (candidate key) for storage_type.';
comment on column storage_type.storage_type_location is 'Root directory for each storage_type';

alter table only storage_type
add constraint pk_storage_type primary key (storage_type_id);

alter table only storage_type
add constraint uq_storage_type_storage_type_name unique (storage_type_name);

alter table only storage_type
add constraint uq_storage_type_storage_type_tag unique (storage_type_tag);


create table storage_type_dimension (
  storage_type_id           bigint                not null,
  domain_id                 bigint                not null,
  dimension_id              bigint                not null,
  dimension_order           smallint,
  dimension_extent          double precision,
  dimension_elements        bigint,
  dimension_cache           bigint,
  dimension_origin          double precision,
  indexing_type_id          smallint,
  reference_system_id       bigint,
  index_reference_system_id bigint,
  reverse_index             boolean default false not null
);
comment on table storage_type_dimension is 'Configuration: Association between storage type and dimensions. Used TO define dimensionality of storage type';
comment on column storage_type_dimension.storage_type_id is 'Part of composite primary key for storage_type_dimension (Other keys are domain_id, dimension_id). Foreign key to storage_type.';
comment on column storage_type_dimension.domain_id is 'Part of composite primary key for storage_type_dimension (Other keys are storage_type_id, dimension_id). Foreign key to dimension_domain and indirect reference to domain.';
comment on column storage_type_dimension.dimension_id is 'Part of composite primary key for storage_type_dimension (Other keys are storage_type_id, domain_id). Foreign key to dimension_domain and indirect reference to dimension.';
comment on column storage_type_dimension.dimension_order is 'Order of dimension in storage type. Should be 1-based sequence but increments are not important, only sort order.';
comment on column storage_type_dimension.dimension_extent is 'Size of storage units along each dimension expressed in reference system units.';
comment on column storage_type_dimension.dimension_elements is 'Number of elements along each dimension for regularly indexed dimensions. Ignored for irregularly indexed dimensions such as time.';
comment on column storage_type_dimension.dimension_cache is 'Caching (e.g. netCDF chunk) size in each dimension.';
comment on column storage_type_dimension.dimension_origin is 'Origin of storage unit indexing scheme expressed in reference system units.';
comment on column storage_type_dimension.indexing_type_id is 'Foreign key to indexing_type lookup table.';
comment on column storage_type_dimension.reference_system_id is 'Foreign key to reference_system lookup table for intra-storage-unit indexing.';
comment on column storage_type_dimension.index_reference_system_id is 'Foreign key to reference_system lookup table for external storage unit indexing.';
comment on column storage_type_dimension.reverse_index is 'Flag indicating whether sense of indexing values should be the reverse of the array indices (e.g. Latitude with spatial origin in UL corner)';

alter table only storage_type_dimension
add constraint pk_storage_type_dimension primary key (storage_type_id, domain_id, dimension_id);

alter table only storage_type_dimension
add constraint uq_storage_type_dimension_storage_type_dimension unique (storage_type_id, dimension_id);
comment on constraint uq_storage_type_dimension_storage_type_dimension on storage_type_dimension is 'Unique constraint to ensure each dimension is only represented once in each storage_type';

create index fki_storage_type_dimension_dimension_domain on storage_type_dimension using btree (domain_id, dimension_id);

create index fki_storage_type_dimension_indexing_type on storage_type_dimension using btree (indexing_type_id);

create index fki_storage_type_dimension_reference_system on storage_type_dimension using btree (reference_system_id);

create index fki_storage_type_dimension_storage_type on storage_type_dimension using btree (storage_type_id);

alter table only storage_type_dimension
add constraint fk_storage_type_dimension_dimension_domain foreign key (domain_id, dimension_id) references dimension_domain (domain_id, dimension_id) on update cascade;

alter table only storage_type_dimension
add constraint fk_storage_type_dimension_indexing_type foreign key (indexing_type_id) references indexing_type (indexing_type_id) on update cascade on delete cascade;

alter table only storage_type_dimension
add constraint fk_storage_type_dimension_reference_system foreign key (reference_system_id) references reference_system (reference_system_id) on update cascade on delete cascade;

alter table only storage_type_dimension
add constraint fk_storage_type_dimension_storage_type foreign key (storage_type_id) references storage_type (storage_type_id) on update cascade on delete cascade;


create table storage_type_dimension_property (
  storage_type_id  bigint                 not null,
  domain_id        bigint                 not null,
  dimension_id     bigint                 not null,
  property_id      bigint                 not null,
  attribute_string character varying(128) not null
);
comment on table storage_type_dimension_property is 'Configuration: Metadata properties of dimension in storage type';
comment on column storage_type_dimension_property.storage_type_id is 'Part of composite foreign key to storage_type_dimension (other keys are domain_id and dimension_id). Also indirect reference to storage_type.';
comment on column storage_type_dimension_property.domain_id is 'Part of composite foreign key to storage_type_dimension (other keys are storage_type_id and dimension_id). Also indirect reference to dimension_domain and domain.';
comment on column storage_type_dimension_property.dimension_id is 'Part of composite foreign key to storage_type_dimension (other keys are storage_type_id and domain_id). Also indirect reference to dimension_domain and dimension.';
comment on column storage_type_dimension_property.property_id is 'Foreign key to property lookup table';
comment on column storage_type_dimension_property.attribute_string is 'String representation of attribute value';

alter table only storage_type_dimension_property
add constraint pk_storage_type_dimension_property primary key (storage_type_id, domain_id, dimension_id, property_id);

create index fki_storage_type_dimension_attribute_property on storage_type_dimension_property using btree (property_id);

create index fki_storage_type_dimension_attribute_storage_type_dimension on storage_type_dimension_property using btree (storage_type_id, domain_id, dimension_id);

alter table only storage_type_dimension_property
add constraint fk_storage_type_dimension_attribute_storage_type_dimension foreign key (storage_type_id, domain_id, dimension_id) references storage_type_dimension (storage_type_id, domain_id, dimension_id) on update cascade on delete cascade;

alter table only storage_type_dimension_property
add constraint fk_storage_type_dimension_property_property foreign key (property_id) references property (property_id) on update cascade on delete cascade;


create table storage_type_measurement_type (
  storage_type_id         bigint not null,
  measurement_metatype_id bigint not null,
  measurement_type_id     bigint not null,
  datatype_id             smallint,
  measurement_type_index  smallint,
  nodata_value            double precision
);
comment on table storage_type_measurement_type is 'Configuration: Associations between n-dimensional data structure types and measurement types (i.e. variables) (many-many)';
comment on column storage_type_measurement_type.storage_type_id is 'Part of composite primary key (other keys are measurement_metatype_id and measurement_type_id). Also foreign key to storage type.';
comment on column storage_type_measurement_type.measurement_metatype_id is 'Part of composite primary key (other keys are storage_type_id and measurement_type_id). Also foreign key to measurement_type and indirect reference to measurement_metatype.';
comment on column storage_type_measurement_type.measurement_type_id is 'Part of composite primary key (other keys are storage_type_id and measurement_metatype_id). Also foreign key to measurement_type.';
comment on column storage_type_measurement_type.datatype_id is 'Foreign key to datatype lookup table.';
comment on column storage_type_measurement_type.measurement_type_index is 'Order of measurement_type in storage unit.
N.B: May be superfluous.';
comment on column storage_type_measurement_type.nodata_value is 'Value used to indicate no-data in storage unit measurement type.';

alter table only storage_type_measurement_type
add constraint pk_storage_measurement_type primary key (storage_type_id, measurement_metatype_id, measurement_type_id);

alter table only storage_type_measurement_type
add constraint uq_storage_type_measurement_type_storage_type_id_measurement_ty unique (storage_type_id, measurement_type_index);

create index fki_storage_type_masurement_type_datatype on storage_type_measurement_type using btree (datatype_id);

create index fki_storage_type_measurement_type_measurement_type on storage_type_measurement_type using btree (measurement_metatype_id, measurement_type_id);

create index fki_storage_type_measurement_type_storage_type on storage_type_measurement_type using btree (storage_type_id);

alter table only storage_type_measurement_type
add constraint fk_storage_type_measurement_type_datatype foreign key (datatype_id) references datatype (datatype_id) on update cascade on delete cascade;

alter table only storage_type_measurement_type
add constraint fk_storage_type_measurement_type_measurement_type foreign key (measurement_metatype_id, measurement_type_id) references measurement_type (measurement_metatype_id, measurement_type_id) on update cascade on delete cascade;

alter table only storage_type_measurement_type
add constraint fk_storage_type_measurement_type_storage_type foreign key (storage_type_id) references storage_type (storage_type_id) on update cascade on delete cascade;


create table storage (
  storage_type_id      bigint  not null,
  storage_id           bigint  not null,
  storage_version      integer not null,
  storage_location     character varying(354),
  md5_checksum         character(32),
  storage_bytes        bigint,
  spatial_footprint_id bigint
);
comment on table storage is 'Data: n-dimensional data structure instances';
comment on column storage.storage_type_id is 'Part of compound primary key for storage (other keys are storage_id and storage_version). Also indirect reference to storage_type.';
comment on column storage.storage_id is 'Part of compound primary key for storage (other keys are storage_type_id and storage_version).';
comment on column storage.storage_version is 'Part of compound primary key for storage (other keys are storage_type_id and storage_id). Should be zero for current version to keep queries simple.';
comment on column storage.storage_location is 'Partial path to storage unit file. Must be appended to storage_type.storage_type_location to create fully qualified path.';
comment on column storage.md5_checksum is 'MD5 checksum for storage unit file';
comment on column storage.storage_bytes is 'Number of bytes in storage unit file';
comment on column storage.spatial_footprint_id is 'Foreign key to spatial_footprint';

alter table only storage
add constraint pk_storage primary key (storage_type_id, storage_id, storage_version);

alter table only storage
add constraint uq_storage_storage_location unique (storage_location);

create index fki_ndarray_footprint_ndarray_type on storage using btree (storage_type_id);

create index fki_storage_spatial_footprint on storage using btree (spatial_footprint_id);

create index fki_storage_storage_type on storage using btree (storage_type_id, storage_type_id);

alter table only storage
add constraint fk_spatial_footprint foreign key (spatial_footprint_id) references spatial_footprint (spatial_footprint_id);

alter table only storage
add constraint fk_storage_storage_type foreign key (storage_type_id) references storage_type (storage_type_id) on update cascade on delete cascade;

create sequence storage_id_seq
start with 100
increment by 1
no minvalue
no maxvalue
cache 1;



create table storage_dataset (
  storage_type_id bigint  not null,
  storage_id      bigint  not null,
  storage_version integer not null,
  dataset_type_id bigint  not null,
  dataset_id      bigint  not null
);
comment on table storage_dataset is 'Data: Association between storage and dataset instances (many-many)';
comment on column storage_dataset.storage_type_id is 'Part of composite primary key for storage_dataset relational entity (Other keys are storage_id, storage_version, dataset_type_id, dataset_id). Part of composite foreign key to storage and indirect association with storage_type.';
comment on column storage_dataset.storage_id is 'Part of composite primary key for storage_dataset relational entity (Other keys are storage_type_id, storage_version, dataset_type_id, dataset_id). Part of composite foreign key to storage.';
comment on column storage_dataset.storage_version is 'Part of composite primary key for storage_dataset relational entity (Other keys are storage_type_id, storage_id, dataset_type_id, dataset_id). Part of composite foreign key to storage.';
comment on column storage_dataset.dataset_type_id is 'Part of composite primary key for storage_dataset relational entity (Other keys are storage_type_id, storage_id, storage_version, dataset_id). Part of composite foreign key to dataset and indirect association with dataset_type.';
comment on column storage_dataset.dataset_id is 'Part of composite primary key for storage_dataset relational entity (Other keys are storage_type_id, storage_id, storage_version, dataset_type_id). Part of composite foreign key to dataset.';

alter table only storage_dataset
add constraint pk_storage_dataset primary key (storage_type_id, storage_id, storage_version, dataset_type_id, dataset_id);

create index fki_storage_dataset_dataset on storage_dataset using btree (dataset_type_id, dataset_id);

create index fki_storage_dataset_storage on storage_dataset using btree (storage_type_id, storage_id, storage_version);

alter table only storage_dataset
add constraint fk_storage_dataset_dataset foreign key (dataset_type_id, dataset_id) references dataset (dataset_type_id, dataset_id) on update cascade on delete cascade;

alter table only storage_dataset
add constraint fk_storage_dataset_storage foreign key (storage_type_id, storage_id, storage_version) references storage (storage_type_id, storage_id, storage_version) on update cascade on delete cascade;


create table storage_dimension (
  storage_type_id         bigint  not null,
  storage_id              bigint  not null,
  storage_version         integer not null,
  domain_id               bigint  not null,
  dimension_id            bigint  not null,
  storage_dimension_index integer not null,
  storage_dimension_min   double precision,
  storage_dimension_max   double precision
);
comment on table storage_dimension is 'Data: Association between storage and dimensions. Used to define attributes for each dimension in storage instances';
comment on column storage_dimension.storage_type_id is 'Part of composite primary key for storage_dimension relational entity (Other keys are storage_id, storage_version, domain_id, dimension_id). Part of composite foreign key to storage and indirect association with storage_type.';
comment on column storage_dimension.storage_id is 'Part of composite primary key for storage_dimension relational entity (Other keys are storage_type_id, storage_version, domain_id, dimension_id). Part of composite foreign key to storage.';
comment on column storage_dimension.storage_version is 'Part of composite primary key for storage_dimension relational entity (Other keys are storage_type_id, storage_id, domain_id, dimension_id). Part of composite foreign key to storage.';
comment on column storage_dimension.domain_id is 'Part of composite primary key for storage_dimension relational entity (Other keys are storage_type_id, storage_id, storage_version, dimension_id). Part of composite foreign key to storage_type_dimension and indirect reference to domain.';
comment on column storage_dimension.dimension_id is 'Part of composite primary key for storage_dimension relational entity (Other keys are storage_type_id, storage_id, storage_version, domain_id). Part of composite foreign key to storage_type_dimension and indirect reference to dimension.';
comment on column storage_dimension.storage_dimension_index is 'Value used to index a portion of a dataset within a storage unit, e.g. timeslice reference time. May be null when a storage unit has more than one index value for a given dataset (e.g. lat/lon).';
comment on column storage_dimension.storage_dimension_min is 'Minimum indexing value for a portion of a dataset in a storage unit in a particular dimension.';
comment on column storage_dimension.storage_dimension_max is 'Maximum indexing value for a portion of a dataset in a storage unit in a particular dimension.';

alter table only storage_dimension
add constraint pk_storage_dimension primary key (storage_type_id, storage_id, storage_version, domain_id, dimension_id);

create index fki_storage_dimension_storage on storage_dimension using btree (storage_type_id, storage_id, storage_version);

create index fki_storage_dimension_storage_type_dimension on storage_dimension using btree (storage_type_id, domain_id, dimension_id);

create index idx_storage_dimension_storage_dimension_index on storage_dimension using btree (storage_dimension_index);

create index idx_storage_dimension_storage_dimension_max on storage_dimension using btree (storage_dimension_max);

create index idx_storage_dimension_storage_dimension_min on storage_dimension using btree (storage_dimension_max);

alter table only storage_dimension
add constraint fk_storage_dimension_storage foreign key (storage_type_id, storage_id, storage_version) references storage (storage_type_id, storage_id, storage_version) on update cascade on delete cascade;

alter table only storage_dimension
add constraint fk_storage_dimension_storage_type_dimension foreign key (storage_type_id, domain_id, dimension_id) references storage_type_dimension (storage_type_id, domain_id, dimension_id);

