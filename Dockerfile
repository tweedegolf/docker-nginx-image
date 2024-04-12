FROM ghcr.io/tweedegolf/debian:bookworm

ARG NGINX_PACKAGE_SRC="https://nginx.org/packages/debian/"

RUN set -x \
# Create nginx group and user
  && cat /etc/group \
  && groupadd --system --gid 111 nginx \
  && useradd --system --gid nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 111 nginx \
# Load nginx apt key
  && \
  export NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
  export NGINX_GPGKEY_PATH=/usr/share/keyrings/nginx-archive-keyring.gpg; \
  export GNUPGHOME="$(mktemp -d)"; \
  found=''; \
  for server in \
    hkp://keyserver.ubuntu.com:80 \
    pgp.mit.edu \
  ; do \
    echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
    gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
  done; \
  test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
  gpg --export "$NGINX_GPGKEY" > "$NGINX_GPGKEY_PATH" ; \
  rm -rf "$GNUPGHOME"; \
# Add nginx debian repository
  echo "deb [signed-by=$NGINX_GPGKEY_PATH] ${NGINX_PACKAGE_SRC} bookworm nginx" >> /etc/apt/sources.list.d/nginx.list \
  && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
      nginx \
      nginx-module-xslt \
      nginx-module-geoip \
      nginx-module-image-filter \
      nginx-module-njs \
      gettext-base \
      curl; \
# Clear download cache
  apt-get remove --purge --auto-remove -y \
  && rm -rf \
    /var/lib/apt/lists/* \
#    /etc/apt/sources.list.d/nginx.list \
# Link standard access and error logfiles to docker outputs
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
