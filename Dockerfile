ARG FROM_IMAGE='usgs/centos'
FROM $FROM_IMAGE


RUN yum install -y epel-release && \
    yum install -y nginx && \
    yum clean all && \
    rm -rf /etc/nginx /usr/share/nginx/html && \
    mkdir -p /etc/nginx /usr/share/nginx/html


COPY ./html/ /usr/share/nginx/html
COPY ./conf/ /etc/nginx/

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
      -subj '/C=XX/ST=Example/L=Example/O=Company Name/OU=Org/CN=localhost'

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log


EXPOSE 80
EXPOSE 443
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]