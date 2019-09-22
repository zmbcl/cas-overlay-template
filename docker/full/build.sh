#!/bin/bash

# enable experimental features https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md
export DOCKER_BUILDKIT=1

image_tag=(`cat ../../gradle.properties | grep "cas.version" | cut -d= -f2`)

echo "Building CAS docker image tagged as [$image_tag]"
# read -p "Press [Enter] to continue..." any_key;

docker build $1 --build-arg VERSION=$image_tag --tag="org.apereo.cas/cas:$image_tag" --file Dockerfile ../.. \
  && echo "Built CAS image successfully tagged as org.apereo.cas/cas:$image_tag" \
  && docker images "org.apereo.cas/cas:$image_tag"
