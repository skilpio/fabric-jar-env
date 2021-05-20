#!/bin/bash

buildJar(){
  from=$1
  to=$2
  echo "Transferring JAR ..."
  cp $from $to
  echo "Transferring DONE"
}

buildGradle() {
    cd "$1" > /dev/null
    echo "Gradle build"
    gradle build shadowJar
    retval=$?
    if [ $retval -ne 0 ]; then
      exit $retval
    fi
    cp build/libs/chaincode.jar $2
    retval=$?
    if [ $retval -ne 0 ]; then
      exit $retval
    fi
    cd "$SAVED" >/dev/null
}

buildMaven() {
    cd "$1" > /dev/null
    echo "Maven build"
    mvn compile package
    retval=$?
    if [ $retval -ne 0 ]; then
      exit $retval
    fi
    cp target/chaincode.jar $2
    retval=$?
    if [ $retval -ne 0 ]; then
      exit $retval
    fi
    cd "$SAVED" >/dev/null
}

buildNative() {
    from=${1}
    to=${2}
    echo "Transferring directories"
    cp -a "${from}/." "${to}"
    echo "Transferring DONE"
}

source /root/.sdkman/bin/sdkman-init.sh

echo "build.sh args: $*"

# Attempt to set APP_HOME
# Resolve links: $0 may be a link
PRG="$0"
echo "build.sh args: $*"
env | sort

# Need this for relative symlinks.
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done
SAVED="`pwd`"
cd "`dirname \"$PRG\"`" >/dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" >/dev/null

APP_NAME="build.sh"
APP_BASE_NAME=`basename "$0"`

if [ -d "/chaincode/output" ]
then
    rm -rf /chaincode/output/*
else
    mkdir -p /chaincode/output/
fi

if [ -d "${APP_HOME}/chaincode/build/out" ]
then
    rm -rf ${APP_HOME}/chaincode/build/out/*
else
    mkdir -p ${APP_HOME}/chaincode/build/out
fi

>&2 echo "START build.sh"

if [ -f "/chaincode/input/src/chaincode.jar" ]
then
    echo "BuildJar"
    buildJar /chaincode/input/src/chaincode.jar /chaincode/output/
elif [ -f "/chaincode/input/src/build.gradle" ]
then
    echo "buildGradle"
    buildGradle /chaincode/input/src/ /chaincode/output/
elif [ -d "/chaincode/input/lib" ] && [ -d "/chaincode/input/bin" ]
then
    buildNative /chaincode/input /chaincode/output
elif [ -f "/chaincode/input/build.gradle" ]
then
    echo "BuildGradle"
    buildGradle /chaincode/input/ /chaincode/output/
elif [ -f "/chaincode/input/src/bin/chaincode-impl" ]
then
    echo "BuildNative"
    buildNative /chaincode/input/src/ /chaincode/output/
elif [ -f "/chaincode/input/src/pom.xml" ]
then
    echo "BuildMaven"
    buildMaven /chaincode/input/src/ /chaincode/output/
elif [ -f "/chaincode/input/pom.xml" ]
then
    buildMaven /chaincode/input/ /chaincode/output/
else
    >&2 echo "Not build.gralde nor pom.xml found in chaincode source, don't know how to build chaincode"
    >&2 echo "Project folder content:"
    >&2 find /chaincode/input/src/ -name "*" -exec ls -ld '{}' \;
    exit 255
fi