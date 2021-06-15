#!/usr/bin/env bash
mkdir -p .pub-cache

cat <<EOF > ~/.pub-cache/credentials.json
{
  "accessToken":"$accessToken",
  "refreshToken":"$refreshToken",
  "tokenEndpoint":"$tokenEndpoint",
  "scopes":[$scopes],
  "expiration":$expiration
}
EOF

cd datahub_common
pub publish -f
cd ..
pub publish -f