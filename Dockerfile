##############################################################################
# Dockerfile to build Atlassian Bamboo container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ENV VERSION  0.0.0

RUN set -x \
  && apk add git tar xmlstarlet --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p /opt/atlassian/bamboo \
  && mkdir -p /var/opt/atlassian/application-data/bamboo

ADD https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-$VERSION.tar.gz /tmp

RUN set -x \
  && tar xvfz /tmp/atlassian-bamboo-$VERSION.tar.gz --strip-components=1 -C /opt/atlassian/bamboo \
  && rm /tmp/atlassian-bamboo-$VERSION.tar.gz

RUN set -x \
  && sed --in-place 's/#bamboo.home=C:\/bamboo\/bamboo-home/bamboo.home=\/var\/opt\/atlassian\/application-data\/bamboo/' /opt/atlassian/bamboo/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties

RUN set -x \
  && touch -d "@0" "/opt/atlassian/bamboo/bin/setenv.sh" \
  && touch -d "@0" "/opt/atlassian/bamboo/conf/server.xml"

ADD files/entrypoint /usr/local/bin/entrypoint

RUN set -x \
  && chown -R daemon:daemon /usr/local/bin/entrypoint \
  && chown -R daemon:daemon /opt/atlassian/bamboo \
  && chown -R daemon:daemon /var/opt/atlassian/application-data/bamboo

EXPOSE 8085
EXPOSE 54663

USER daemon

ENTRYPOINT  ["/usr/local/bin/entrypoint"]
