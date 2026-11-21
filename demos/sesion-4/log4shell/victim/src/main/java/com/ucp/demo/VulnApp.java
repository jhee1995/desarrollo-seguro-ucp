package com.ucp.demo;

import com.sun.net.httpserver.HttpServer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

/**
 * App deliberadamente VULNERABLE a Log4Shell (CVE-2021-44228), solo para el
 * laboratorio del curso. Registra el valor de la cabecera X-Api-Version con
 * log4j 2.14.1, que procesa lookups ${...} en el mensaje. Un atacante que envie
 * ${jndi:ldap://.../Exploit} logra que la JVM cargue y ejecute una clase remota.
 *
 * NO EXPONER NUNCA A UNA RED. Corre solo en la red Docker aislada del lab.
 */
public class VulnApp {
    private static final Logger log = LogManager.getLogger(VulnApp.class);

    public static void main(String[] args) throws Exception {
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
        server.createContext("/", exchange -> {
            String apiVersion = exchange.getRequestHeaders().getFirst("X-Api-Version");
            if (apiVersion == null) {
                apiVersion = exchange.getRequestHeaders().getFirst("User-Agent");
            }
            // <-- LINEA VULNERABLE: el valor no confiable pasa por el formateo
            //     de log4j, que evalua lookups ${jndi:...}
            log.info("Peticion recibida · X-Api-Version: {}", apiVersion);

            byte[] body = "ok\n".getBytes(StandardCharsets.UTF_8);
            exchange.sendResponseHeaders(200, body.length);
            exchange.getResponseBody().write(body);
            exchange.close();
        });
        server.start();
        log.info("VulnApp (log4j 2.14.1) escuchando en http://0.0.0.0:8080");
    }
}
