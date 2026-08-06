# Java Hello World — Multi-Stage Docker Practice

A minimal Java HTTP server with no external dependencies, built with Maven.
Purpose-built for practicing multi-stage Docker builds — Java is a good
example because the JDK + Maven build environment is large (400MB+), while
the actual runtime only needs a JRE and a single small `.jar` file.

## What it does

- `GET /` — returns `Hello, World from Java!`
- `GET /health` — returns `{"status":"ok"}`

Uses only `com.sun.net.httpserver` (built into the JDK) — no frameworks, no
external Maven dependencies. Keeps the build fast and the focus on Docker,
not on the app itself.

## Requirements to build/run locally

- JDK 17+
- Maven 3.6+

## Building and running locally

```bash
mvn clean package
java -jar target/app.jar
```

Server starts on port `8080` by default. Override with the `PORT` env var:

```bash
PORT=9090 java -jar target/app.jar
```

Visit `http://localhost:8080/` and `http://localhost:8080/health`.

## Project structure

```
.
├── pom.xml
├── src/main/java/com/example/app/App.java
├── .gitignore
└── README.md
```

## What to know before writing the multi-stage Dockerfile

- `mvn clean package` produces a runnable jar at `target/app.jar` (the
  `finalName` is set to `app` in `pom.xml`, so the artifact name is
  predictable regardless of version bumps).
- The build stage needs a JDK + Maven image (e.g. `maven:3.9-eclipse-temurin-17`).
- The final runtime stage only needs a JRE (e.g. `eclipse-temurin:17-jre-alpine`)
  and the single `app.jar` file — nothing else from the build stage needs to
  be copied over.
- Run command for the final image: `java -jar app.jar`.
- Default port is `8080` — expose that in the Dockerfile.
