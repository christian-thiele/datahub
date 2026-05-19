<p align="center">
<img src="https://datahubproject.net/logo_shadow.svg" />
</p>

<h2 align="center">DataHub Aperture Frontend</h2>
<p align="center">
This library is part of the DataHub Project.<br/>
<a href="https://datahubproject.net">https://datahubproject.net</a>
</p>

> DataHub is a Cloud Development Ecosystem aiming to bring the power of Dart into the Cloud.

*DataHub is still under development and is not to be considered production ready. Comprehensive documentation is yet to
be released.*

---

### Overview

`datahub_aperture_frontend` is the Flutter Web SPA that pairs with [`datahub_aperture`](../datahub_aperture). It
connects to the Aperture REST API and provides a browser-based admin UI for managing DataHub resources.

**Features**

- Browse and search resources exposed by `ApertureApi`
- Create, view, and edit resource elements with auto-generated forms
- Field types supported: text, int, double, bool, enum, timestamp, file, geometry (GeoJSON), nested objects, and lists
- Relation fields rendered as lookup menus backed by the API
- Column filtering on resource list views
- Task Manager module — lists task invocations, streams live logs, shows progress and duration
- OIDC authorization code flow with PKCE (automatic token refresh via shared preferences)
- Configurable seed color theming at runtime
- Localized in English and German

---

### Running locally

```bash
cd packages/datahub_aperture_frontend
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:8080/aperture
```

---

### Docker

A production image is built with a multi-stage Dockerfile: Flutter compiles a release web build, then Caddy serves the
static files.

```bash
# Build from repo root
docker build -f packages/datahub_aperture_frontend/docker/Dockerfile -t datahub_aperture_frontend .
```

**Environment variables**

| Variable    | Default      | Description                                                                     |
|-------------|--------------|---------------------------------------------------------------------------------|
| `BASE_HREF` | `/`          | Sub-path the app is served under (e.g. `/admin/`). Must start and end with `/`. |
| `API_URL`   | `$BASE_HREF` | Base URL of the `datahub_aperture` backend API.                                 |

```bash
docker run -p 8080:80 \
  -e BASE_HREF=/admin/ \
  -e API_URL=https://api.example.com/ \
  datahub_aperture_frontend
```
