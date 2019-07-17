FROM dtr.example.com/base/java8:rel.1.0.0

MAINTAINER Liozza<zlprasy@example.com>

# replace container_files
WORKDIR /opt
ADD http://repo.example.com/docker_res/pinpoint-apm/pinpoint-apm-1.1.zip /tmp/
RUN yum install -y unzip  && unzip /tmp/pinpoint-apm-1.1.zip -d /opt/
