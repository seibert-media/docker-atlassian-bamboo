##############################################################################
# Dockerfile to build Atlassian Bamboo container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ARG VERSION
ARG MYSQL_JDBC_VERSION

ENV BAMBOO_INST /opt/atlassian/bamboo 
ENV BAMBOO_HOME /var/opt/atlassian/application-data/bamboo
ENV SYSTEM_USER bamboo
ENV SYSTEM_GROUP bamboo
ENV SYSTEM_HOME /home/bamboo

RUN set -x \
  && apk add git tar xmlstarlet --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p $BAMBOO_INST \
  && mkdir -p $BAMBOO_HOME

RUN set -x \
  && mkdir -p /home/$SYSTEM_USER \
  && addgroup -S $SYSTEM_GROUP \
  && adduser -S -D -G $SYSTEM_GROUP -h $SYSTEM_GROUP -s /bin/sh $SYSTEM_USER \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP /home/$SYSTEM_USER

ADD https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-$VERSION.tar.gz /tmp
ADD https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_JDBC_VERSION.tar.gz /tmp

RUN set -x \
  && tar xvfz /tmp/atlassian-bamboo-$VERSION.tar.gz --strip-components=1 -C $BAMBOO_INST \
  && rm /tmp/atlassian-bamboo-$VERSION.tar.gz

RUN set -x \
  && tar xvfz /tmp/mysql-connector-java-$MYSQL_JDBC_VERSION.tar.gz mysql-connector-java-$MYSQL_JDBC_VERSION/mysql-connector-java-$MYSQL_JDBC_VERSION-bin.jar -C $BAMBOO_INST/atlassian-bamboo/WEB-INF/lib/ \
  && rm /tmp/mysql-connector-java-$MYSQL_JDBC_VERSION.tar.gz

RUN set -x \
  && touch -d "@0" "$BAMBOO_INST/bin/setenv.sh" \
  && touch -d "@0" "$BAMBOO_INST/conf/server.xml" \
  && touch -d "@0" "$BAMBOO_INST/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties"

ADD files/service /usr/local/bin/service
ADD files/entrypoint /usr/local/bin/entrypoint

RUN set -x \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP /usr/local/bin/service \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP /usr/local/bin/entrypoint \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP $BAMBOO_INST \
  && chown -R $SYSTEM_USER:$SYSTEM_GROUP $BAMBOO_HOME

EXPOSE 8085 54663

USER $SYSTEM_USER

VOLUME $BAMBOO_HOME

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["/usr/local/bin/service"]
