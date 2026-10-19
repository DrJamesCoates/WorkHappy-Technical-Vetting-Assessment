# Assessments

Small Rails 7.2 / PostgreSQL / TypeScript app. Needs only Docker.

## Run

```sh
docker compose up --build            # app on http://localhost:3000
docker compose run --rm web bin/rails db:seed   # ~200k assessments, takes a minute or two
```

Log in with `admin1@example.com` … `admin10@example.com`, password `password` (one admin per company).

## Useful

```sh
docker compose run --rm web bin/rails test      # Minitest
docker compose run --rm web bin/rails console
docker compose run --rm web yarn typecheck
```
