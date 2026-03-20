FROM maven:3.9.9-eclipse-temurin-11 AS builder

WORKDIR /src
COPY pom.xml /src/
COPY anc /src/anc/
COPY explorer /src/explorer/
COPY grpc /src/grpc/

RUN mvn -B -DskipTests package

FROM jetty:9.4.57-jre11
LABEL maintainer="Steven Barth <stbarth@cisco.com>"

COPY --from=builder /src/explorer/target/*.war /var/lib/jetty/webapps/ROOT.war
USER root
RUN mkdir -p /var/lib/yangcache && chown -R jetty:jetty /var/lib/yangcache
USER jetty

EXPOSE 8080
