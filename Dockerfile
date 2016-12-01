##############################################################################
# Dockerfile to build Atlassian Bamboo container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ARG VERSION

ENV BAMBOO_INST /opt/atlassian/bamboo 
ENV BAMBOO_HOME /var/opt/atlassian/application-data/bamboo

RUN set -x \
  && apk add git tar xmlstarlet --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p $BAMBOO_INST \
  && mkdir -p $BAMBOO_HOME

ADD https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-$VERSION.tar.gz /tmp

RUN set -x \
  && tar xvfz /tmp/atlassian-bamboo-$VERSION.tar.gz --strip-components=1 -C $BAMBOO_INST \
  && rm /tmp/atlassian-bamboo-$VERSION.tar.gz

RUN set -x \
  && touch -d "@0" "$BAMBOO_INST/bin/setenv.sh" \
  && touch -d "@0" "$BAMBOO_INST/conf/server.xml" \
  && touch -d "@0" "$BAMBOO_INST/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties"

ADD files/entrypoint /usr/local/bin/entrypoint

RUN set -x \
  && chown -R daemon:daemon /usr/local/bin/entrypoint \
  && chown -R daemon:daemon $BAMBOO_INST \
  && chown -R daemon:daemon $BAMBOO_HOME

EXPOSE 8085
EXPOSE 54663

USER daemon

VOLUME $BAMBOO_HOME

ENTRYPOINT  ["/usr/local/bin/entrypoint"]
