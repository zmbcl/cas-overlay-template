#!/bin/bash
CONTAINER_NAME=${1:-cas}
image_tag=(`cat ../../gradle.properties | grep "cas.version" | cut -d= -f2`)
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker run --rm -d -p 9010:9010 -p 8443:8443 -p 8080:8080 --name $CONTAINER_NAME org.apereo.cas/cas:$image_tag
docker logs cas -f