# Flask + MySQL + Redis — Hello World App

A minimal but realistic 3-tier app: a Flask web service, a MySQL database, and a
Redis cache. Built to be containerized (see **Note for DevOps** below) — this
repo intentionally does **not** include a `Dockerfile` or `docker-compose.yml`,
those are the next step.

## What it does

- `GET /` — increments a visit counter.
  - First checks Redis for a cached count (cache hit).
  - On a cache miss, reads/writes the real count in MySQL, then repopulates
    Redis with a short TTL. This is the standard **cache-aside pattern**.
- `GET /health` — checks connectivity to both MySQL and Redis independently
  and returns `200` if both are reachable, or `503` if either is down. Meant
  to be wired into a container `HEALTHCHECK` or an orchestrator's
  liveness/readiness probe.

## Tech stack

| Component | Choice |
|---|---|
| Web framework | Flask 3 |
| WSGI server (production) | Gunicorn |
| Database | MySQL 8 (via `PyMySQL`) |
| Cache | Redis 7 (via `redis-py`) |

## Configuration

The app takes **no hardcoded config** — everything is read from environment
variables, so it behaves the same locally, in Docker, or in Kubernetes.

| Variable | Default | Description |
|---|---|---|
| `PORT` | `5000` | Port Flask/Gunicorn listens on |
| `DB_HOST` | `localhost` | MySQL host |
| `DB_PORT` | `3306` | MySQL port |
| `DB_USER` | `root` | MySQL user |
| `DB_PASSWORD` | *(empty)* | MySQL password |
| `DB_NAME` | `appdb` | MySQL database name |
| `REDIS_HOST` | `localhost` | Redis host |
| `REDIS_PORT` | `6379` | Redis port |
| `REDIS_DB` | `0` | Redis logical DB index |
| `CACHE_TTL_SECONDS` | `10` | How long the cached count is valid |

See `.env.example` for a ready-to-copy template.

## Running it locally (without Docker)

You'll need a local MySQL and Redis instance running, or use `localhost` if
you already have them installed.

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# edit .env with your local MySQL/Redis details

export $(cat .env | xargs)   # or use python-dotenv if you prefer
python app.py
```

Visit `http://localhost:5000/` — each refresh should increment the counter.
Visit `http://localhost:5000/health` to check dependency status.

### Database setup

The app auto-creates its own table (`visits`) on startup if it doesn't exist,
so no manual schema/migration step is required. You only need an empty
database created with the name in `DB_NAME`, owned by the user in `DB_USER`.

## Running in production (without Docker)

Use Gunicorn instead of the Flask dev server:

```bash
gunicorn --bind 0.0.0.0:5000 --workers 3 app:app
```

## Note for DevOps — what you need to know before dockerizing this

1. **This app is 12-factor / stateless.** No local files are written, no
   in-memory session state — safe to run multiple replicas behind a load
   balancer.
2. **Startup ordering matters.** On boot, the app tries to create its MySQL
   table immediately. If MySQL isn't ready yet (common when containers start
   at the same time), it logs a warning and does **not** crash — but the
   table won't exist until a request comes in and the DB is reachable, or the
   container restarts after the DB is up. Recommend adding a
   `depends_on.condition: service_healthy` (with a MySQL healthcheck) in
   Compose, or a retry/init-container in Kubernetes.
3. **Health endpoint is ready to use as-is**: `GET /health` returns `200`
   when both MySQL and Redis are reachable, `503` otherwise. Good fit for a
   Docker `HEALTHCHECK` instruction or an orchestrator probe.
4. **All config is env-var driven** — see the table above. Nothing to patch
   in code to point this at different hosts/creds; just set the environment
   in the Compose file / secrets.
5. **Recommended run command inside the container**: `gunicorn --bind
   0.0.0.0:$PORT --workers 3 app:app` (don't use the Flask dev server in the
   final image).
6. **Default port is `5000`** — expose that in the Dockerfile and map it in
   Compose.
7. Only three files matter for the image: `app.py`, `requirements.txt`, and
   whatever `.env`/secrets mechanism you choose for config — no build steps,
   no static assets, no extra system packages beyond a MySQL client library
   if you don't use PyMySQL's pure-Python driver (we do, so no extra OS
   packages are required for MySQL connectivity).

## Project structure

```
.
├── app.py              # Flask app
├── requirements.txt    # Python dependencies
├── .env.example        # Sample environment config
├── .gitignore
└── README.md
```
