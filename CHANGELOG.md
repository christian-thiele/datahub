# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-08-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`boost` - `v2.0.1`](#boost---v201)
 - [`datahub` - `v0.18.0-dev.25`](#datahub---v0180-dev25)
 - [`datahub_aperture` - `v0.1.0-dev.17`](#datahub_aperture---v010-dev17)
 - [`datahub_aperture_frontend` - `v0.1.0-dev.14`](#datahub_aperture_frontend---v010-dev14)
 - [`datahub_codegen` - `v0.18.0-dev.15`](#datahub_codegen---v0180-dev15)
 - [`datahub_postgres` - `v0.18.0-dev.22`](#datahub_postgres---v0180-dev22)

---

#### `boost` - `v2.0.1`

 - **FIX**(boost): fixed semaphore ensuring FIFO order.
 - **FIX**: fixed repository / website in pubpsec files for all packages.

#### `datahub` - `v0.18.0-dev.25`

 - **PERF**(api): optimized route pattern matching using regex cache.
 - **FIX**(datahub): fixed early logging errors.
 - **FIX**(config): minor fixes and improvements.
 - **FIX**(config): fixed config directive ordering.
 - **FIX**(config): fixed List<String> configuration values with default values.
 - **FIX**(datahub): fixed GeometryCollection parsing and writing.
 - **FIX**(datahub): fixed minor websocket bugs.
 - **FIX**(datahub): fixed signal shutdown.
 - **FIX**(test): improved docker environment management.
 - **FIX**(datahub): improved logging for pool.
 - **FIX**(datahub): added missing dispose for pool.
 - **FIX**(datahub): fixed pool queueing behavior.
 - **FIX**(datahub): fixed potential pool leak.
 - **FIX**: fixed repository / website in pubpsec files for all packages.
 - **FEAT**(datahub): added first and any methods to DataRepository.
 - **FEAT**(config): added environment variable references.
 - **FEAT**(config): added near-miss config warnings.
 - **FEAT**(config): improved error handling for config files.
 - **FEAT**(config): added enum config validation and improved error handling.
 - **FEAT**(config): added lazy config reference resolution and improved error handling.
 - **FEAT**(config): improved config performance and error handling.
 - **FEAT**(api): graceful shutdown with timeout on ApiService.
 - **FEAT**(datahub): added pool maintenance timer instead of passive eviction.
 - **FEAT**(datahub): added pool queue limit.
 - **FEAT**(datahub): tightened pool give and added adopt method to avoid silent corruption.

#### `datahub_aperture` - `v0.1.0-dev.17`

 - **FEAT**(datahub_aperture_frontend): reworked GeoEditor to support all Geometry types.

#### `datahub_aperture_frontend` - `v0.1.0-dev.14`

 - **FIX**: fixed repository / website in pubpsec files for all packages.
 - **FEAT**(datahub_aperture_frontend): reworked GeoEditor to support all Geometry types.

#### `datahub_codegen` - `v0.18.0-dev.15`

 - **FIX**: fixed repository / website in pubpsec files for all packages.

#### `datahub_postgres` - `v0.18.0-dev.22`

 - **FEAT**(datahub): added first and any methods to DataRepository.
 - **FEAT**(datahub): added pool maintenance timer instead of passive eviction.
 - **FEAT**(datahub_postgres): added connection pool queue limit.


## 2026-07-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub_postgres` - `v0.18.0-dev.21`](#datahub_postgres---v0180-dev21)

---

#### `datahub_postgres` - `v0.18.0-dev.21`

 - **FIX**(datahub_postgres): fixed json type handling.


## 2026-07-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub_postgres` - `v0.18.0-dev.20`](#datahub_postgres---v0180-dev20)

---

#### `datahub_postgres` - `v0.18.0-dev.20`

 - **FIX**(datahub_postgres): fixed array and json type filters.
 - **FIX**(datahub_postgres): correct literals for array types.
 - **FIX**: fixed repository / website in pubpsec files for all packages.


## 2026-07-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub` - `v0.18.0-dev.24`](#datahub---v0180-dev24)
 - [`datahub_aperture` - `v0.1.0-dev.16`](#datahub_aperture---v010-dev16)
 - [`datahub_aperture_frontend` - `v0.1.0-dev.13`](#datahub_aperture_frontend---v010-dev13)
 - [`datahub_codegen` - `v0.18.0-dev.14`](#datahub_codegen---v0180-dev14)
 - [`datahub_postgres` - `v0.18.0-dev.19`](#datahub_postgres---v0180-dev19)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `datahub_codegen` - `v0.18.0-dev.14`
 - `datahub_postgres` - `v0.18.0-dev.19`

---

#### `datahub` - `v0.18.0-dev.24`

 - **FIX**(test): sort direction in memory repository.

#### `datahub_aperture` - `v0.1.0-dev.16`

 - **FEAT**(aperture): add metadata annotations and fix revisable check.
 - **FEAT**(aperture): search bar and sorting.

#### `datahub_aperture_frontend` - `v0.1.0-dev.13`

 - **FEAT**(aperture): add confirmation dialog for resource deletion.
 - **FEAT**(aperture): sort direction visualization.
 - **FEAT**(aperture): search bar and sorting.


## 2026-07-15

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub_aperture` - `v0.1.0-dev.15`](#datahub_aperture---v010-dev15)
 - [`datahub_aperture_frontend` - `v0.1.0-dev.9`](#datahub_aperture_frontend---v010-dev9)

---

#### `datahub_aperture` - `v0.1.0-dev.15`

 - **FEAT**(aperture): add search functionality with test data generation.

#### `datahub_aperture_frontend` - `v0.1.0-dev.9`

 - **FEAT**(aperture): add search functionality with test data generation.


## 2026-06-26

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub` - `v0.18.0-dev.23`](#datahub---v0180-dev23)
 - [`datahub_aperture` - `v0.1.0-dev.14`](#datahub_aperture---v010-dev14)
 - [`datahub_codegen` - `v0.18.0-dev.13`](#datahub_codegen---v0180-dev13)
 - [`datahub_postgres` - `v0.18.0-dev.18`](#datahub_postgres---v0180-dev18)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `datahub_aperture` - `v0.1.0-dev.14`
 - `datahub_codegen` - `v0.18.0-dev.13`
 - `datahub_postgres` - `v0.18.0-dev.18`

---

#### `datahub` - `v0.18.0-dev.23`

 - **FIX**(datahub): fixed exports.


## 2026-06-09

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub` - `v0.18.0-dev.22`](#datahub---v0180-dev22)
 - [`datahub_aperture` - `v0.1.0-dev.13`](#datahub_aperture---v010-dev13)
 - [`datahub_codegen` - `v0.18.0-dev.12`](#datahub_codegen---v0180-dev12)
 - [`datahub_postgres` - `v0.18.0-dev.17`](#datahub_postgres---v0180-dev17)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `datahub_aperture` - `v0.1.0-dev.13`
 - `datahub_codegen` - `v0.18.0-dev.12`
 - `datahub_postgres` - `v0.18.0-dev.17`

---

#### `datahub` - `v0.18.0-dev.22`

 - **FEAT**(data): added in-memory filter evaluation.


## 2026-05-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub` - `v0.18.0-dev.21`](#datahub---v0180-dev21)
 - [`datahub_aperture` - `v0.1.0-dev.12`](#datahub_aperture---v010-dev12)
 - [`datahub_codegen` - `v0.18.0-dev.11`](#datahub_codegen---v0180-dev11)
 - [`datahub_postgres` - `v0.18.0-dev.16`](#datahub_postgres---v0180-dev16)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `datahub_aperture` - `v0.1.0-dev.12`
 - `datahub_codegen` - `v0.18.0-dev.11`
 - `datahub_postgres` - `v0.18.0-dev.16`

---

#### `datahub` - `v0.18.0-dev.21`

 - **FIX**(config): fixed config reference resolution.


## 2026-05-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub` - `v0.18.0-dev.20`](#datahub---v0180-dev20)
 - [`datahub_aperture` - `v0.1.0-dev.11`](#datahub_aperture---v010-dev11)
 - [`datahub_codegen` - `v0.18.0-dev.10`](#datahub_codegen---v0180-dev10)
 - [`datahub_postgres` - `v0.18.0-dev.15`](#datahub_postgres---v0180-dev15)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `datahub_aperture` - `v0.1.0-dev.11`
 - `datahub_codegen` - `v0.18.0-dev.10`
 - `datahub_postgres` - `v0.18.0-dev.15`

---

#### `datahub` - `v0.18.0-dev.20`

 - **REFACTOR**(config): restructured Configuration and exposed more api.
 - **FIX**(test): fixed environment configuration.
 - **FEAT**(config): config reference syntax.


## 2026-05-20

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub_codegen` - `v0.18.0-dev.9`](#datahub_codegen---v0180-dev9)

---

#### `datahub_codegen` - `v0.18.0-dev.9`

 - **FIX**(codegen): fixed nullable enum with library prefix.


## 2026-05-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub_aperture_frontend` - `v0.1.0-dev.8`](#datahub_aperture_frontend---v010-dev8)

---

#### `datahub_aperture_frontend` - `v0.1.0-dev.8`

 - **DOCS**: fixed README.md.


## 2026-05-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub` - `v0.18.0-dev.19`](#datahub---v0180-dev19)
 - [`datahub_aperture_frontend` - `v0.1.0-dev.7`](#datahub_aperture_frontend---v010-dev7)
 - [`datahub_aperture` - `v0.1.0-dev.10`](#datahub_aperture---v010-dev10)
 - [`datahub_codegen` - `v0.18.0-dev.8`](#datahub_codegen---v0180-dev8)
 - [`datahub_postgres` - `v0.18.0-dev.14`](#datahub_postgres---v0180-dev14)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `datahub_aperture` - `v0.1.0-dev.10`
 - `datahub_codegen` - `v0.18.0-dev.8`
 - `datahub_postgres` - `v0.18.0-dev.14`

---

#### `datahub` - `v0.18.0-dev.19`

 - **FIX**(ci): fixed timeout argon2id test on ci.

#### `datahub_aperture_frontend` - `v0.1.0-dev.7`

 - **FIX**(docker): use flutter:beta base image.


## 2026-05-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub` - `v0.18.0-dev.18`](#datahub---v0180-dev18)
 - [`datahub_aperture` - `v0.1.0-dev.9`](#datahub_aperture---v010-dev9)
 - [`datahub_codegen` - `v0.18.0-dev.7`](#datahub_codegen---v0180-dev7)
 - [`datahub_postgres` - `v0.18.0-dev.13`](#datahub_postgres---v0180-dev13)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `datahub_aperture` - `v0.1.0-dev.9`
 - `datahub_codegen` - `v0.18.0-dev.7`
 - `datahub_postgres` - `v0.18.0-dev.13`

---

#### `datahub` - `v0.18.0-dev.18`

 - **FIX**(ci): skip httpbin related tests due to CI issues.


## 2026-05-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`datahub` - `v0.18.0-dev.17`](#datahub---v0180-dev17)
 - [`datahub_aperture` - `v0.1.0-dev.8`](#datahub_aperture---v010-dev8)
 - [`datahub_codegen` - `v0.18.0-dev.6`](#datahub_codegen---v0180-dev6)
 - [`datahub_postgres` - `v0.18.0-dev.12`](#datahub_postgres---v0180-dev12)

---

#### `datahub` - `v0.18.0-dev.17`

 - **FIX**(ci): use melos conventions.
 - **FIX**: argon2 test ci problem.

#### `datahub_aperture` - `v0.1.0-dev.8`

 - **FIX**(ci): use melos conventions.

#### `datahub_codegen` - `v0.18.0-dev.6`

 - **FIX**(ci): use melos conventions.

#### `datahub_postgres` - `v0.18.0-dev.12`

 - **FIX**(ci): use melos conventions.
 - **FIX**: timeout test port.

