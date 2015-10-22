create table spectral_parameters (
    measurement_metatype_id bigint not null,
    measurement_type_id     bigint not null
);
comment on table spectral_parameters is 'Configuration: Spectral band parameters';

alter table only spectral_parameters
add constraint pk_spectral_parameters primary key (measurement_metatype_id, measurement_type_id);

create index fki_spectral_parameters_measurement_type on spectral_parameters using btree (measurement_metatype_id, measurement_type_id);

alter table only spectral_parameters
add constraint fk_spectral_parameters_measurement_metatype foreign key (measurement_metatype_id, measurement_type_id) references measurement_type (measurement_metatype_id, measurement_type_id);


