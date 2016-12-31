# docker-atlassian-bamboo

This is a Docker-Image for Atlassian Bamboo based on [Alpine Linux](http://alpinelinux.org/), which is kept as small as possible.

## Features

* Small image size
* Setting application context path
* Setting JVM xms and xmx values
* Setting proxy parameters in server.xml to run it behind a reverse proxy (TOMCAT_PROXY_* ENV)
* Includes MySQL JDBC driver

## Variables

* TOMCAT_PROXY_NAME
* TOMCAT_PROXY_PORT
* TOMCAT_PROXY_SCHEME
* TOMCAT_CONTEXT_PATH
* JVM_MEMORY_MIN
* JVM_MEMORY_MAX

## Ports
* 8085
* 54663

## Build container
Specify the application version in the build command:

```bash
docker build --build-arg VERSION=x.x.x --build-arg MYSQL_JDBC_VERSION=5.1.40 . 
```

## Getting started

Run Bamboo standalone and navigate to `http://[dockerhost]:8085` to finish configuration:

```bash
docker run -tid -p 8085:8085 -p 54663:54663 seibertmedia/atlassian-bamboo:latest
```

Run Bamboo standalone with customised jvm settings and navigate to `http://[dockerhost]:8085` to finish configuration:

```bash
docker run -tid -p 8085:8085 -p 54663:54663 -e JVM_MEMORY_MIN=2g -e JVM_MEMORY_MAX=4g seibertmedia/atlassian-bamboo:latest
```

Specify persistent volume for Bamboo data directory:

```bash
docker run -tid -p 8085:8085 -p 54663:54663 -v bamboo_data:/var/opt/atlassian/application-data/bamboo seibertmedia/atlassian-bamboo:latest
```

Run Bamboo behind a reverse (SSL) proxy and navigate to `https://build.yourdomain.com`:

```bash
docker run -d -e TOMCAT_PROXY_NAME=build.yourdomain.com -e TOMCAT_PROXY_PORT=443 -e TOMCAT_PROXY_SCHEME=https seibertmedia/atlassian-bamboo:latest
```

Run Bamboo behind a reverse (SSL) proxy with customised jvm settings and navigate to `https://build.yourdomain.com`:

```bash
docker run -d -e TOMCAT_PROXY_NAME=build.yourdomain.com -e TOMCAT_PROXY_PORT=443 -e TOMCAT_PROXY_SCHEME=https -e JVM_MEMORY_MIN=2g -e JVM_MEMORY_MAX=4g seibertmedia/atlassian-bamboo:latest
```
