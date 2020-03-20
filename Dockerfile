#services
#follow instructions in comments to fill the gaps
FROM alpine:latest
MAINTAINER GGMethos <ggmethos@autistici.org>

USER root

RUN apk upgrade --update-cache --available

RUN apk update && apk upgrade

RUN apk add cmake openssl clang gcc g++ make libffi-dev openssl-dev ninja
#create services user
RUN addgroup services && \
        adduser -h /home/services -s /sbin/nologin -D -G services services && \
        chown -R services /home/services && \
        mkdir -p /data && \
        chown -R services /data


VOLUME ["/tarball"]

COPY /tarball/anope-2.0.7-source.tar.gz /home/services/

RUN cd /home/services && mkdir /home/services/tarball && cp /home/services/anope-2.0.7-source.tar.gz /home/services/tarball && cd /home/services/tarball && tar xfvz anope-2.0.7-source.tar.gz

RUN cd /home/services/tarball/anope-2.0.7-source/ && ls -la && ls -la

#########################################################################

#CUSTOM CONFIGURATION

VOLUME ["/secrets"]

mkdir /home/services/tarball/anope-2.0.7-source/customconfigs

COPY /secrets/config.cache /home/services/tarball/anope-2.0.7-source/customconfigs

COPY /secrets/services.conf /home/services/tarball/anope-2.0.7-source/customconfigs


#########################################################################

RUN cd /home/services/tarball/anope-2.0.7-source/ && ./Config -nointro -quick

RUN cd /home/services/tarball/anope-2.0.7-source/ && ls -la && cd /home/services/tarball/anope-2.0.7-source/build && make && make install

RUN cp /home/services/tarball/anope-2.0.7-source/customconfigs/config.cache /home/services/tarball/anope-2.0.7-source/

RUN cp /home/services/tarball/anope-2.0.7-source/customconfigs/services.conf /home/services/services/conf/

USER services

RUN cd /home/services/services/bin/ && ./services

#put configuration files in proper place

#switch user to services

#finally start services

