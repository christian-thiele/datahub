FROM ghcr.io/cirruslabs/flutter:stable AS build

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