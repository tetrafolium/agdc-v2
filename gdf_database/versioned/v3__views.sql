create materialized view storage_type_dimension_view as
    select
        storage_type.storage_type_id,
        storage_type_dimension.dimension_order       as creation_order,
        domain.domain_id,
        dimension.dimension_id,
        storage_type_dimension.reference_system_id,
        storage_type.storage_type_name,
        dimension.dimension_name,
        dimension.dimension_tag,
        domain.domain_name,
        reference_system.reference_system_name,
        reference_system.reference_system_definition,
        indexing_type.indexing_type_name,
        storage_type_dimension.dimension_origin,
        storage_type_dimension.dimension_extent,
        index_reference_system.reference_system_unit as index_unit,
        storage_type_dimension.dimension_elements,
        reference_system.reference_system_unit,
        storage_type_dimension.dimension_cache
    from (((((((storage_type storage_type
    join storage_type_dimension storage_type_dimension using (storage_type_id))
                join dimension_domain using (domain_id, dimension_id))
               join domain using (domain_id))
              join dimension using (dimension_id))
             join reference_system using (reference_system_id))
            join reference_system index_reference_system on ((storage_type_dimension.index_reference_system_id = index_reference_system.reference_system_id)))
           join indexing_type using (indexing_type_id))
    order by storage_type.storage_type_id, storage_type_dimension.dimension_order;

create materialized view dimension_indices_view as
    select
        storage_type_dimension_view.storage_type_id,
        storage_type_dimension_view.domain_id,
        storage_type_dimension_view.dimension_id,
        reference_system_indexing.reference_system_id,
        reference_system_indexing.array_index,
        reference_system_indexing.indexing_name,
        reference_system_indexing.measurement_metatype_id,
        reference_system_indexing.measurement_type_id
    from (storage_type_dimension_view
        join reference_system_indexing using (reference_system_id))
    order by storage_type_dimension_view.storage_type_id, storage_type_dimension_view.dimension_id,
        reference_system_indexing.array_index;


create materialized view dimension_properties_view as
    select
        storage_type_dimension_view.storage_type_id,
        storage_type_dimension_view.domain_id,
        storage_type_dimension_view.dimension_id,
        storage_type_dimension_view.dimension_name,
        property.property_name,
        storage_type_dimension_property.attribute_string,
        datatype.datatype_name
    from (((storage_type_dimension_view
            join storage_type_dimension_property storage_type_dimension_property using (storage_type_id, domain_id, dimension_id))
            join property using (property_id))
           join datatype using (datatype_id))
    order by storage_type_dimension_view.storage_type_id, storage_type_dimension_view.creation_order,
        property.property_name;


