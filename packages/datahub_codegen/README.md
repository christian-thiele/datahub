<p align="center">
<img src="https://datahubproject.net/logo_shadow.svg" />
</p>

<h2 align="center">DataHub Code Generation Lib</h2>
<p align="center">
This library is part of the DataHub Project.<br/>
<a href="https://datahubproject.net">https://datahubproject.net</a>
</p>

![Pub Version](https://img.shields.io/pub/v/datahub?color=2CB7F6&label=pub.dev&logo=dart&style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/christian-thiele/datahub?style=flat-square)
![Pub Likes](https://img.shields.io/pub/likes/datahub?color=2CB7F6&label=pub.dev%20likes&style=flat-square)

> DataHub is a Cloud Development Ecosystem aiming to bring the power of Dart into the Cloud.

*DataHub is still under development and is not to be considered production ready. Comprehensive documentation is yet to
be released.*

---

### Features

This library contains generators for:
- TransferObjects
- DataBeans
- BrokerApis
- HubClients / Providers

### Usage

Add `datahub_codegen` and `build_runner` to the `dev_dependencies` of your projects
`pubspec.yaml` file, or simply run:

```shell
$ dart pub add --dev datahub_codegen build_runner
```

To build generated code run:

```shell
$ dart run build_runner build
```


[1]: https://github.com/christian-thiele/datahub