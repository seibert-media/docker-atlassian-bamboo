##############################################################################
# Dockerfile to build Atlassian Bamboo container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <info@seibert-media.net>

ARG VERSION

ENV BAMBOO_INST /opt/bamboo 
ENV BAMBOO_HOME /var/opt/bamboo
ENV SYSTEM_USER bamboo
ENV SYSTEM_GROUP bamboo
ENV SYSTEM_HOME /home/bamboo

RUN set -x \
  && apk add git su-exec tar xmlstarlet wget ca-certificates openssh --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p ${BAMBOO_INST} \
  && mkdir -p ${BAMBOO_HOME}

RUN set -x \
  && mkdir -p ${SYSTEM_HOME} \
  && addgroup -S ${SYSTEM_GROUP} \
  && adduser -S -D -G ${SYSTEM_GROUP} -h ${SYSTEM_HOME} -s /bin/sh ${SYSTEM_USER} \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${SYSTEM_HOME}

RUN set -x \
  && wget -nv -O /tmp/atlassian-bamboo-${VERSION}.tar.gz https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${VERSION}.tar.gz \
  && tar xfz /tmp/atlassian-bamboo-${VERSION}.tar.gz --strip-components=1 -C ${BAMBOO_INST} \
  && rm /tmp/atlassian-bamboo-${VERSION}.tar.gz \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${BAMBOO_INST} \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${BAMBOO_HOME}

RUN set -x \
  && touch -d "@0" "${BAMBOO_INST}/bin/setenv.sh" \
  && touch -d "@0" "${BAMBOO_INST}/conf/server.xml" \
  && touch -d "@0" "${BAMBOO_INST}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties"

ADD files/service /usr/local/bin/service
ADD files/entrypoint /usr/local/bin/entrypoint

EXPOSE 8009 8085 54663

VOLUME ${BAMBOO_HOME}

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["/usr/local/bin/service"]
