NGINX
=====

An image for running NGINX on CentOS.


Getting Started
---------------

The default build of this image presents a container that runs an NGINX server
on CentOS. The server runs in the foreground to keep Docker happy.

### Image Layout

Static content is served from the `/usr/share/nginx/html` directory within
the container. Very simple boiler plate files are provided to assist in
determining the server is running properly. A typical deployment of this
image will replace all contents of this folder with the actual content to
be served.

Logs are sent to STDOUT/STDERR using symbolic links inside the container.
Check the `log_format` directive in `conf/nginx.conf` for information on log
formatting. A best effort has been made to log the `X-CLIENT-IP` as well as
`X-FORWARDED-FOR` HTTP headers.

Configuration files are stored in `/etc/nginx`. The main configuration file is
`/etc/nginx/nginx.conf`. It sets up basic server parameters and includes
any `*.conf` files from the `/etc/nginx/default.d` directory. These are included
from within each `server` directive in the main configuration file. An empty
`00-server.conf` file is provided and may be modified/replaced to specify
redirects, rewrites, or other customizations as needed for the target
deployment.

### SSL

The image configures NGINX to listen on both port 8080 (HTTP) as well as 8443
(HTTPS). One may expose either or both of these ports as necessary for the
target deployment using the `-p` switch when starting the container. No effort
is made to redirect all HTTP traffic to HTTPS, however this could be
accomplished on a case by case basis using customized configuration files
`conf/http.conf` and `conf/https.conf`.

Since the image has no knowledge of the host on which it may be deployed,
it relies on the administrator providing the SSL certificate files. These
certificate files include `/etc/nginx/ssl/server.key` and
`/etc/nginx/ssl/server.crt`. These files may be symbolic links to actual (more
appropriately named) SSL certificate files. These files (or the
`/etc/nginx/ssl` directory itself) may be mounted into the container from the
host system.

The system administirator must generate the SSL certificate files and make them
available to the container. These files may be generated using `OpenSSL` or any
other valid method.


Building
--------

The `Dockerfile` provided with this package provides everything that is
needed to build the image. The build system must have Docker installed in
order to build the image.

```
$ cd PROJECT_ROOT
$ docker build -t usgs/nginx .
```
> Note: PROJECT_ROOT should be replaced with the path to where you have
>       cloned this project on the build system.


Running a Container
-------------------

The container host must have Docker installed in order to run the image as a
container. Then the image can be pulled and a container can be started directly.

```
$ docker run usgs/nginx
```

### Swtiches

Any standard Docker switches may be provided on the command line when running
a container. Some specific switches of interest are documented below.

#### Ports
```
-p HOST_PORT:CONTAINER_PORT
```
Within the container, the NGINX server is configured to listen on both port 8080
and 8443 (for HTTP and HTTPS respectively). An administrator may choose to
expose either or both of these ports to the host container system.

#### Mounts
```
-v HOST_DIRECTORY:CONTAINER_DIRECTORY
```
Content may be copied directly into the running container using a
`docker cp ...` command, alternatively one may choose to simply expose a host
volume to the container for easier access. A typical use-case may be to
expose the host SSL certificate files to the container. A less common use-case
may include exposing local static files to serve as the NGINX `root` directory.

### Examples

Run an NGINX server in a container. Expose container ports 8080 and 8443. Use
the host `/etc/pki/nginx` directory as the container `/etc/nginx/ssl` directory
(SSL certificates should already exist in the host directory).

```
$ docker run \
  --name example-nginx \
  -v /etc/pki/nginx:/etc/nginx/ssl \
  -p 8443:8443 \
  -p 8080:8080 \
  usgs/nginx:latest
```

At this point a user should be able to access the NGINX server in a browser
from any system (assuming proper firewall configurations).
```
https://containerhost:8443/index.html
http://containerhost:8080/index.html
```


Debugging
---------

You may connect to a running container using the following command
```
$ docker exec -it --user root CONTAINER_NAME /bin/bash
```
> Note: CONTAINER_NAME should be the name provided to Docker when creating the
>       container initially. If not provided explicitly, Docker may have
>       assigned a random name. A container ID may also be used.

You may tail the container logs using the following commands
```
$ docker exec -it --user root CONTAINER_NAME tail -f /var/log/nginx/access.log
$ docker exec -it --user root CONTAINER_NAME tail -f /var/log/nginx/error.log
```

