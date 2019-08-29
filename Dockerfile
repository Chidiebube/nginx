ARG FROM_IMAGE='usgs/centos:latest'
FROM $FROM_IMAGE

LABEL maintainer="Eric Martinez <emartinez@usgs.gov>" \
      dockerfile_version="1.0.0"


COPY ./nginx.repo /etc/yum.repos.d/nginx.repo

RUN yum install -y nginx && \
    yum clean all && \
    rm -rf /etc/nginx /usr/share/nginx/html && \
    mkdir -p /etc/nginx /usr/share/nginx/html && \
    mkdir -p /startup-hooks && \
    chown -R usgs-user \
        /etc/nginx \
        /startup-hooks \
        /usr/share/nginx \
        /var/log/nginx \
        /var/cache/nginx \
        /var/run \
        /run

COPY ./conf/ /etc/nginx/
COPY ./html/ /usr/share/nginx/html
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./healthcheck.sh /healthcheck.sh

# Create a self-signed certificate so the build doesn't blow up by default.
# If actually using SSL, a user will likely want to provide actual certificate
# files for the target deployment.
RUN openssl \
      req \
      -x509 \
      -nodes \
      -newkey rsa:4096 \
      -keyout /etc/nginx/ssl/server.key \
      -out /etc/nginx/ssl/server.crt \
      -days 365 \
      -subj '/C=XX/ST=Example/L=Example/O=Company Name/OU=Org/CN=localhost' && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

HEALTHCHECK \
        --interval=15s \
        --timeout=5s \
        --start-period=1m \
        --retries=2 \
    CMD /healthcheck.sh

EXPOSE 8080
EXPOSE 8443
STOPSIGNAL SIGQUIT

USER usgs-user
CMD [ "/docker-entrypoint.sh" ]
