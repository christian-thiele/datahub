cd ../datahub_aperture_frontend
flutter build web --debug --no-tree-shake-icons
cd ../datahub_aperture
dart run bin/bundler.dart ../datahub_aperture_frontend/build/web ./lib/frontend_bundle.dart frontendBundle