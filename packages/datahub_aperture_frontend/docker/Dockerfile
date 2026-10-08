FROM debian:bookworm-slim AS build

ARG FLUTTER_VERSION=3.47.2
RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --no-analytics --enable-web && flutter precache --web

WORKDIR /app

COPY . .

WORKDIR /app/packages/datahub_aperture_frontend
RUN flutter pub get
RUN flutter build web --release --no-tree-shake-icons --base-href /__BASE_HREF__/

FROM caddy:2-alpine
LABEL org.opencontainers.image.source=https://github.com/christian-thiele/datahub

COPY --from=build /app/packages/datahub_aperture_frontend/build/web /usr/share/caddy

COPY packages/datahub_aperture_frontend/docker/Caddyfile /etc/caddy/Caddyfile
COPY packages/datahub_aperture_frontend/docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
