# Build: compila el jar con JDK 8
FROM maven:3.8-openjdk-8 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -q -B -DskipTests package

# Runtime: JDK 8u181 — ANTERIOR a 8u191, por lo que
# com.sun.jndi.ldap.object.trustURLCodebase es true por defecto y la carga
# remota de clases via JNDI funciona (necesario para reproducir el RCE).
FROM openjdk:8u181-jre-alpine
WORKDIR /app
COPY --from=build /app/target/vulnapp.jar /app/vulnapp.jar
EXPOSE 8080
CMD ["java", "-jar", "/app/vulnapp.jar"]
