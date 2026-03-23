# Setup

To get started with DataHub, follow these steps:

## 1. Prerequisites
Ensure you have the latest Dart SDK installed on your machine. You can download it from the [official Dart website](https://dart.dev/get-dart).

## 2. Install Melos
DataHub uses Melos for managing its monorepo. Install it globally with:

```bash
dart pub global activate melos
```

## 3. Clone the Repository
Clone the DataHub repository to your local machine:

```bash
git clone https://github.com/schultek/datahub.git
cd datahub
```

## 4. Bootstrap the Project
Run melos bootstrap to install dependencies and link packages:

```bash
melos bootstrap
```

## 5. Verify Installation
Run the tests to ensure everything is set up correctly:

```bash
melos run test
```
