## 0.1.0-dev.1

- FEAT(lints): Initial release.
- FEAT(lints): Analysis rules for services and dependency injection
  (`prefer_instance_find`, `prefer_instance_read`,
  `avoid_zone_context_in_service`, `await_lifecycle_super`,
  `avoid_injection_in_initializer`, `const_service_constructor`).
- FEAT(lints): Analysis rule for enum configuration (`enum_config_requires_values`),
  reported as an error: such a declaration cannot be read at all.
- FEAT(lints): Analysis rules for data classes (`data_class_requires_part`,
  `data_class_extends_generated`, `data_class_const_constructor`).
- FEAT(lints): Analysis rule for the postgres repository mixins
  (`postgres_repository_requires_super_initialize`).
- FEAT(lints): Analysis rule for Aperture relations
  (`aperture_relation_requires_relation_id`).
- FEAT(lints): Assists to generate a `ServiceInstance`, convert a class into a data class
  and add a `Find` injection field.
