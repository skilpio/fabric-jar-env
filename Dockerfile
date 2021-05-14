FROM hyperledger/fabric-javaenv:1.4.8 as dependencies

FROM adoptopenjdk/openjdk11
COPY --from=dependencies /root/chaincode-java/ /root/chaincode-java/
COPY --from=dependencies /root/chaincode-java/gradlew /root/chaincode-java/gradlew
COPY --from=dependencies /usr/bin/maven /usr/bin/maven
COPY --from=dependencies /root/.sdkman/ /root/.sdkman/
SHELL ["/bin/bash", "-c"]
ENV PATH="/usr/bin/maven/bin:/usr/bin/maven/:${PATH}"
COPY --from=dependencies /root/chaincode-java /root/chaincode-java
COPY --from=dependencies /root/.m2 /root/.m2
RUN mkdir -p /chaincode/input
RUN mkdir -p /chaincode/output
WORKDIR /root/chaincode-java
RUN rm -f build.sh
ADD build.sh /root/chaincode-java/
RUN rm -f start
ADD start /root/chaincode-java/
