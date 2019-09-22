# syntax=docker/dockerfile:experimental
FROM adoptopenjdk/openjdk11:alpine-slim AS overlay
COPY ./src cas-overlay/src/
COPY ./gradle/ cas-overlay/gradle/
COPY ./gradlew ./settings.gradle ./build.gradle ./gradle.properties /cas-overlay/
RUN --mount=type=cache,target=/root/.gradle echo "org.gradle.daemon=false" > ~/.gradle/gradle.properties \
    && echo "org.gradle.configureondemand=true" >> ~/.gradle/gradle.properties \
    && cd cas-overlay \
    && chmod 750 ./gradlew \
    && ./gradlew --version

# build war with all support jars in lib folder rather than in war
RUN --mount=type=cache,target=/root/.gradle cd cas-overlay \
    && ./gradlew clean build -PbuildAll=true  --parallel;

# create fresh keystore (can be volume mapped with real certs by runner)
RUN --mount=type=cache,target=/root/.gradle cd cas-overlay \
    && ./gradlew createKeystore

# put support jars in support folder
# switch to PropertiesLauncher so we can reference external libs
# repackage war without suport jars
RUN cd cas-overlay/build/libs/ && \
    jar xf cas.war && \
    mkdir ../support && \
    rm cas.war && \ 
    mv WEB-INF/lib/cas-server-support*.jar ../support && \
    sed -i 's/WarLauncher/PropertiesLauncher/g' META-INF/MANIFEST.MF && \
    jar --create --file cas.war --manifest=META-INF/MANIFEST.MF --no-compress .

# build runtime image with war and support libs from previous layer
FROM adoptopenjdk/openjdk11:alpine AS cas

LABEL "Organization"="Apereo"
LABEL "Description"="Apereo CAS"

RUN cd / \
    && mkdir -p /etc/cas/config \
    && mkdir -p /etc/cas/services \
    && mkdir -p /etc/cas/saml \
    && mkdir -p cas-overlay \
    && apk update && apk add bash

COPY etc/cas/config/ /etc/cas/config/
COPY etc/cas/services/ /etc/cas/services/
COPY etc/cas/saml/ /etc/cas/saml/
COPY --from=overlay /etc/cas/thekeystore /etc/cas/thekeystore
COPY --from=overlay cas-overlay/build/libs/cas.war cas-overlay/
COPY --from=overlay cas-overlay/build/support cas-overlay/support
EXPOSE 8080 8443
ARG VERSION
ENV VERSION=${VERSION}
ENV PATH $PATH:$JAVA_HOME/bin:.
ENV SUPPORT_LIBS=""
ADD docker/full/start_cas.sh cas-overlay

WORKDIR cas-overlay
ENTRYPOINT ["/cas-overlay/start_cas.sh"]

