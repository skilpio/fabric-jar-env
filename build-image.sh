#!/usr/bin/env bash

docker build --no-cache -t enterprisedlt/fabric-jar-env:1.4.8 .
docker tag enterprisedlt/fabric-jar-env:1.4.8 skilpio/fabric-javaenv:1.4.4
docker push skilpio/fabric-javaenv:1.4.4
