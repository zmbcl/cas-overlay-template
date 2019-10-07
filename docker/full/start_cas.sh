#!/bin/bash

DEFAULT_JVM_ARGS="-Xms1500M -Xmx3000M"
RESULT_JVM_ARGS=${JVM_ARGS:-$DEFAULT_JVM_ARGS}

CLOUD_VAULT_CONFIG=${CLOUD_VAULT_CONFIG:-false}
CLOUD_CONSUL_CONFIG=${CLOUD_CONSUL_CONFIG:-false}
CLOUD_ZOOKEEPER_CONFIG=${CLOUD_ZOOKEEPER_CONFIG:-false}

DEFAULT_SUPPORT_LIBS=actions,geolocation,jpa-util,ldap-core,pac4j-api,pac4j-authentication,pac4j-core,person-directory,themes,token-core-api,validation,validation-core
SUPPORT_LIBS=$DEFAULT_SUPPORT_LIBS,$SUPPORT_LIBS

if [[ ! -z ${SUPPORT_LIBS} ]]; then
    if [[ ! -d /cas-overlay/libs ]] ; then
        mkdir /cas-overlay/libs
    fi
    rm -f /cas-overlay/libs/*
    for SUPPORT_LIB in $(echo $SUPPORT_LIBS | sed "s/,/ /g")
    do
        if [[ ! -z ${SUPPORT_LIB} ]] ; then
            echo "Linking support library ${SUPPORT_LIB}"
            ln -s /cas-overlay/support/cas-server-support-${SUPPORT_LIB}-${VERSION}.jar /cas-overlay/libs/cas-server-support-${SUPPORT_LIB}.jar 
        fi
    done
fi

# turn off some things, mostly cloud config options, make configurable later
CAS_ARGS="--spring.cloud.zookeeper.enabled=${CLOUD_ZOOKEEPER_CONFIG} --spring.cloud.amqp.enabled=false --spring.cloud.vault.enabled=${CLOUD_VAULT_CONFIG} --spring.cloud.consul.enabled=${CLOUD_CONSUL_CONFIG} --eureka.client.enabled=false --spring.zipkin.enabled=false --spring.sleuth.enabled=false --ribbon.eureka.enabled=false --feign.hystrix.enabled=false"
exec /opt/java/openjdk/bin/java -Dcom.sun.management.jmxremote \
  -Dcom.sun.management.jmxremote.port=9010 \
  -Dcom.sun.management.jmxremote.local.only=false \
  -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false \
  -server -noverify \
  -Dloader.path=WEB-INF/classes,WEB-INF/lib,/cas-overlay/libs $RESULT_JVM_ARGS -jar cas.war $CAS_ARGS