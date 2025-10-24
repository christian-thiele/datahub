FROM quay.io/keycloak/keycloak:26.4.2
ADD https://github.com/moparisthebest/static-curl/releases/download/v8.11.0/curl-i386 /bin/curl
USER root
RUN chmod +x /bin/curl
USER 1000

ADD realm-export.json /opt/keycloak/data/import/realm-export.json

HEALTHCHECK --interval=5s --timeout=1s --start-period=30s CMD curl -f http://localhost:8080/realms/master/.well-known/openid-configuration || exit 1

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev"]