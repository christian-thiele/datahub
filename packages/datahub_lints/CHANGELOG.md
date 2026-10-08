## 0.18.0-dev.3

 - **FIX**(lints): add dependency injection assist now adds the initialization in service instances.
 - **FEAT**(lints): added lints for scheduler and workflows.
 - **FEAT**(lints): Recommended set `package:datahub/recommended.yaml`, which enables the lint plugin with best-practice lints switched on.
 - **FEAT**(lints): Lints `reducible_filter_group` and `reducible_sort_group` for filter and sort groups that can be written shorter: empty groups, groups with one element, nested groups, and operands without effect. Both come with a fix that simplifies the group.
 - **FEAT**(lints): Lint `aperture_relation_requires_resource` for an `@ApertureRelation<R>()` whose related class has no `ApertureResource` in the same `ApertureApi` ("Related bean for R not found for ApertureRelation of T").
 - **FEAT**(lints): Lints `reducible_filter_group` and `reducible_sort_group` for filter and sort groups that can be written shorter: empty groups, groups with  one element, nested groups, and operands without effect. Both come with a fix that simplifies the group.
 - **FEAT**(lints): Analysis rule `constant_filter_group` for `Filter.empty` in an `or` group and `Filter.nothing` in an `and` group, which make the group match everything or nothing.
 - **FEAT**(lints): Assist converting an `a.and(b).and(c)` / `a.or(b)` chain into `Filter.andGroup` / `Filter.orGroup`.
 - **FEAT**(lints): added revisable repository lints.
 - **FEAT**(lint): added postgres revisable lints.

## 0.18.0-dev.2

- FEAT(lints): Analysis rule requiring configuration without an in-code default
  to be listed in the package's `resources/defaults.yaml`
  (`config_requires_default`). Packages without that file opt out.

## 0.18.0-dev.1

- FEAT(lints): Initial release.
- FEAT(lints): Analysis rules for services and dependency injection
  (`prefer_instance_find`, `prefer_instance_read`,
  `avoid_zone_context_in_service`, `await_lifecycle_super`,
  `avoid_injection_in_initializer`, `const_service_constructor`).
- FEAT(lints): Analysis rules for lifecycle super call position
  (`super_initialize_first`, `super_dispose_last`), with fixes that move the
  call into place.
- FEAT(lints): Analysis rule for enum configuration (`enum_config_requires_values`),
  reported as an error: such a declaration cannot be read at all.
- FEAT(lints): Analysis rules for data classes (`data_class_requires_part`,
  `data_class_extends_generated`, `data_class_const_constructor`).
- FEAT(lints): Analysis rule for Aperture relations
  (`aperture_relation_requires_relation_id`).
- FEAT(lints): Assists to generate a `ServiceInstance`, convert a class into a data class
  and add a `Find` injection field.
