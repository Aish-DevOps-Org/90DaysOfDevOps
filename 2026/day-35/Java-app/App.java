package com.example.app;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

/**
 * Minimal HTTP server using only the JDK's built-in com.sun.net.httpserver —
 * no external dependencies, so the Maven build stays simple and this project
 * is purely about demonstrating a multi-stage Docker build (JDK+Maven build
 * environment vs. a slim JRE runtime image).
 */
public class App {

    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));

        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);

        server.createContext("/", App::handleHome);
        server.createContext("/health", App::handleHealth);

        server.setExecutor(null); // default executor
        server.start();

        System.out.println("Server started on port " + port);
    }

    private static void handleHome(HttpExchange exchange) throws IOException {
        String response = "Hello, World from Java!\n";
        sendResponse(exchange, 200, response);
    }

    private static void handleHealth(HttpExchange exchange) throws IOException {
        String response = "{\"status\":\"ok\"}\n";
        sendResponse(exchange, 200, response);
    }

    private static void sendResponse(HttpExchange exchange, int statusCode, String body) throws IOException {
        byte[] bytes = body.getBytes();
        exchange.getResponseHeaders().set("Content-Type", "text/plain");
        exchange.sendResponseHeaders(statusCode, bytes.length);
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(bytes);
        }
    }
}
