#!/bin/sh
set -eu

VERSION=$(yq .version < pubspec.yaml)
echo "Deploying version $VERSION"
cd ../..
docker buildx build --platform linux/amd64,linux/arm64 -f packages/datahub_aperture_frontend/docker/Dockerfile -t ghcr.io/christian-thiele/datahub_aperture_frontend:latest -t ghcr.io/christian-thiele/datahub_aperture_frontend:$VERSION .
docker push ghcr.io/christian-thiele/datahub_aperture_frontend:latest
docker push ghcr.io/christian-thiele/datahub_aperture_frontend:$VERSION