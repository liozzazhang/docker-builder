FROM  dtr.example.com/base/centos7-mini@sha256:88d615347f39c00cf598c12f9dd24122b8d45737bfd5a6868434e03c9231d4a0
MAINTAINER Liozza<zlprasy@gmail.com>
LABEL source.image.name=centos7-mini \
      source.image.tag=official \
      source.image.sha256=88d615347f39c00cf598c12f9dd24122b8d45737bfd5a6868434e03c9231d4a0 \
      build.image.name=base18 \
      build.image.version=rel.1.0 \
      maintainer="zlprasy@gmail.com" \
      description="create from centos7 version(https://github.com/CentOS/sig-cloud-instance-images/blob/9a389e11460bd809bb83c5fd4f095dbc8398d8cc/docker/Dockerfile), installed yum packages: supervisor, unzip, consul-template, awscli, gosu, dump-init, tar. \
More details please refer to https://github.com/liozzazhang/docker-builder/"

#Install necessary packages
RUN curl -o  /etc/yum.repos.d/init.repo http://repo.example.com/yum/yum.repos/init.repo  && \
    curl -o /tmp/awscli-bundle.zip http://repo.example.com/downloads/software/awscli/awscli-bundle.zip && \
    curl -o  /usr/local/bin/consul-template http://repo.example.com/downloads/software/consul-template/consul-template && \
    chmod +x /usr/local/bin/consul-template && \
    curl -o /usr/local/bin/gosu http://repo.example.com/downloads/software/gosu/gosu && \
    chmod +x /usr/local/bin/gosu && \
    curl -o /usr/local/bin/dumb-init http://repo.example.com/downloads/software/dumb-init/dumb-init_1.2.1_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    yum install -y supervisor unzip tar yum-plugin-ovl && \
    yum clean all && \
    unzip /tmp/awscli-bundle.zip && \
    ./awscli-bundle/install -b /usr/local/bin/aws && \
    rm -rf /tmp/awscli-bundle.zip && \
    rm -rf awscli-bundle && \
    rm -rf /etc/yum.repos.d/ && \
    rm -rf /etc/supervisord* && \
    echo "export LC_ALL=en_US.UTF-8"  >>  /etc/profile && \
    echo "* soft nofile 64000" >> /etc/security/limits.conf && \
    echo "* soft nproc 32000" >> /etc/security/limits.conf && \
    echo "* hard nproc 32000" >> /etc/security/limits.conf && \
    echo "* hard nofile 64000" >> /etc/security/limits.conf && \
    echo "* hard nproc 32000" >> /etc/security/limits.d/20-nproc.conf

#Add config files
COPY resource/ /
ENTRYPOINT ["/usr/local/bin/dumb-init","/main.sh"]
