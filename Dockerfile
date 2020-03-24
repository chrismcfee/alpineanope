#services
#follow instructions in comments to fill the gaps
FROM alpine:latest
MAINTAINER GGMethos <ggmethos@autistici.org>

EXPOSE 7000

USER root

RUN echo "Anope Services Installation Starting"

RUN apk upgrade --update-cache --available

RUN apk update && apk upgrade

RUN apk add gettext

RUN apk add gnutls

RUN apk add gnutls-dev

RUN apk add gnutls-dbg

RUN apk add gnutls-utils

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

RUN mkdir /home/services/tarball/anope-2.0.7-source/customconfigs/

COPY /secrets/config.cache /home/services/tarball/anope-2.0.7-source/customconfigs/

COPY /secrets/services.conf /home/services/tarball/anope-2.0.7-source/customconfigs/


RUN mkdir -p /home/services/tmpsslcerts && cd /home/services/tmpsslcerts/ && openssl genrsa -out anope.key 2048 && openssl req -new -x509 -key anope.key -out anope.crt -days 1095 -subj /C=CA/ST=Ontario/L=Toronto/O=Coronaviruslol/OU=devops/CN=*.coronavirus.gov

RUN mkdir -p /home/services/sslcerts/

RUN cp /home/services/tmpsslcerts/anope.crt /home/services/sslcerts/

RUN cp /home/services/tmpsslcerts/anope.key /home/services/sslcerts/

RUN cp /home/services/tarball/anope-2.0.7-source/customconfigs/config.cache /home/services/tarball/anope-2.0.7-source/

RUN cd /home/services/tarball/anope-2.0.7-source/ && ./Config -nointro -quick

RUN cd /home/services/tarball/anope-2.0.7-source/ && ls -la && cd /home/services/tarball/anope-2.0.7-source/build && make && make install

RUN cp /home/services/tarball/anope-2.0.7-source/customconfigs/config.cache /home/services/tarball/anope-2.0.7-source/

COPY /secrets/services.conf /home/services/tarball/anope-2.0.7-source/customconfigs/

#need to fix ssl for services link connection

RUN cp /home/services/tarball/anope-2.0.7-source/customconfigs/services.conf /home/services/services/conf/

RUN chown -R services /home/services

#########################################################################

USER services
CMD ["./home/services/services/bin/services", "--nofork"]
