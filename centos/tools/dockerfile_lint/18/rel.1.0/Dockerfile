FROM  dtr.example.com/base/centos7-mini@sha256:88d615347f39c00cf598c12f9dd24122b8d45737bfd5a6868434e03c9231d4a0
MAINTAINER Liozza<zlprasy@gmail.com>
LABEL source.image.name=centos7-mini \
      source.image.tag=official \
      source.image.sha256=88d615347f39c00cf598c12f9dd24122b8d45737bfd5a6868434e03c9231d4a0 \
      build.image.name=dockerfile_lint18 \
      build.image.version=rel.1.0 \
      maintainer="zlprasy@gmail.com" \
      description="create from official centos7-mini version, installed npm packages: dockerfile_lint. \
More details please refer to https://github.com/liozzazhang/docker-builder/"

#Install necessary packages
RUN curl -o  /etc/yum.repos.d/init.repo http://repo.example.com/yum/yum.repos/init.repo && \
    yum install -y npm openssl && \
    yum clean all && \
    npm install -g dockerfile_lint && npm cache clean

#Add config files
COPY resource/ /

WORKDIR /root

ENTRYPOINT ["/usr/bin/dockerfile_lint","-r","/base.yaml"]