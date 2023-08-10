# apt_cacher_ng_docker

This project provides an APT caching service for docker saving network resources.

apt_cacher_ng_docker provides a mechanism for running [apt-cacher ng](https://help.ubuntu.com/community/Apt-Cacher%20NG)
along side docker build and run.  

## Background 
Repeated docker builds of large contexts can be time consuming and waste network
resources. The APT package management tool can be a significant offender of this
waste.  This project allows you to run an apt cacher ng service along side 
your docker builds to save network resources from repeated download of apt
packages resulting on significant speedup with subsequent docker builds.

## Prerequisites 
requires docker, docker compose, and make installed and configured for your user.

## Usage

Simply call the provided up target to start the apt cacher ng service:
```bash
make up
```

## Setting Up Consumers 
There are a number of strategies for setting up a client to take advantage of
this apt cacher ng service.  This section offers several consumer examples. 

### Consumer Option (**Recommended Approach**)

This is the best and recommended approach for consuming this apt cacher ng service.
The result of this method will be reproducible builds e.g., regardless of weather
the apt cacher ng service is used or not docker build cache will not be invalidated.

1. Use  provided make target to start up the apt cacher ng service:
```bash 
make up
```
2. Build you docker image sourcing the provided docker config in this directory(config.json):
```bash
DOCKER_CONFIG=. docker build --network host --file Dockerfile.apt_cacher_ng_consumer_recommended .
```

### Consumer Option 1

This option requires modifying the consumer Dockerfile.  This will invalidate 
your docker cache if the HTTP_PROXY variable changes. This is generally a bad 
option.

1. Add the following to any consumer docker containers that wish to take advantage
of apt caching:
```Dockerfile
...
RUN echo 'Acquire::http { Proxy "http://127.0.0.1:3142"; };' >> /etc/apt/apt.conf.d/01proxy
RUN apt-get update
...
RUN apt-get install -y somepackage
...

```
2. Before building the consumer image start the apt cacher ng service with the provided make target:
```bash
make start_apt_cacher_ng
```
3. Build your docker image with the --network flag provided as follows:
```bash
docker build --network host .
```
or try the example Dockerfile consumer provided with the project:
```bash
docker build --network host --file Dockerfile.apt_cacher_ng_consumer1 .
```

4. Stop the apt-cacher ng service after your container is build with the provided make target:
```bash
make stop_apt_cacher_ng
```

A complete dockerfile is provided in this project for this example (Dockerfile.apt_cacher_ng_consumer1)

### Option 2

This option requires modifying the consumer Dockerfile.  This will invalidate 
your docker cache if the HTTP_PROXY variable changes. This is generally a bad 
option.

1. Add the following to any consumer docker containers that wish to take advantage
of apt caching:
```Dockerfile
...
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV http_proxy "$HTTP_PROXY"
ENV https_proxy "$HTTPS_PROXY"
ENV no_proxy "$NO_PROXY"
...
RUN apt-get update
...
RUN apt-get install -y somepackage
...
```

2. Before building the consumer image start the apt cacher ng service with the provided make target:
```bash
make start_apt_cacher_ng
```
3. Build your docker image with the --network flag and --build-arg flags provided as follows:
```bash
docker build --network host --build-arg HTTP_PROXY=http://127.0.0.1:3142 --build-arg HTTPS_PROXY="http://127.0.0.1:3142" .
```
or try the example Dockerfile consumer provided with the project:
```bash
docker build --network host --file Dockerfile.apt_cacher_ng_consumer2 .
```

4. Stop the apt-cacher ng service after your container is build with the provided make target:
```bash
make stop_apt_cacher_ng
```

A complete dockerfile is provided in this project for this example (Dockerfile.apt_cacher_ng_consumer1)

### Apt-Cacher NG Statistics Dashboard
While Apt-Cacher is running caching statistics can be found via the web interface at: http://127.0.0.1:3142/acng-report.html

### Cache Directory
when you execute "make up" a docker volume is created for apt cache located in the current directory and called ".cache".
This directory cache directory is preserved regardless of the state docker on the host system.  To manually wipe this
cache you can run:
```bash
make clean
```


## Proxy Configuration
The provide apt cacher ng service works behind a proxy. To enable a proxy
set the HTTP_PROXY environmental variable to your desired proxy example:
```bash
HTTP_PROXY=http://someproxy:3124 make build_apt_cacher_ng && make start_apt_cacher_ng
```
The environmental variable can also be set for persistence via your preferred shell or with the following:
```bash
export HTTP_PROXY=http://someproxy:3124
...
...
make build_apt_cacher_ng && make start_apt_cacher_ng
```

## Disabling Apt Cacher Ng ad hoc
Sometimes it may be necessary to disable Apt Cacher Ng. This can be done by 
setting the environmental variable `APT_CACHER_NG_ENABLED` to false.
One-off disabling apt-cacher-ng:
```bash
APT_CACHER_NG_ENABLED=false make up
```
Sometimes it may be necessary to disable apt-cacher-ng persistently in the case
when it is causing issues or during CI processes. This can be done by sourcing
the provided environment file:
```bash
source disable_apt_cacher_ng.env
```

> **⚠️ WARNING:**
> This will only work with the recommended consumer approach with the DOCKER_CONFIG env var.
