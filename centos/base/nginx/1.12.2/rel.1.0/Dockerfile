# use example base image
FROM        dtr.example.com/base/base18@sha256:ca25d8d4e26affa973e4a53f96d4ea03629c4c393b381f936cd29fa290e10ac4
MAINTAINER Liozza<zlprasy@gmail.com>
LABEL source.image.name=base18 \
      source.image.tag=rel.1.0.0 \
      source.image.sha256=ca25d8d4e26affa973e4a53f96d4ea03629c4c393b381f936cd29fa290e10ac4 \
      build.image.name=nginx1_12_2 \
      build.image.version=rel.1.0 \
      maintainer="zlprasy@gmail.com" \
      description="create from base18, installed yum packages: java 1.12.2. \
More details please refer to https://github.com/liozzazhang/docker-builder/"

# install nginx
RUN yum install -y nginx-1.12.2 && \
    yum clean all && \
    rm -rf /etc/nginx/conf.d/*

COPY resource/ /
