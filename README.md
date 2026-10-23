# Unfollowed

## Testes

Execute toda a suíte com RSpec:

```sh
bundle exec rspec
```

## Docker Compose

Crie o arquivo de ambiente e suba a stack:

```sh
test -f .env || cp .env.development.example .env
docker compose up --build
```

Serviços:

- `web`: Rails em http://localhost:3000
- `redis`: Redis 7, usado pelo Sidekiq
- `worker`: processador de jobs Sidekiq

O banco continua SQLite (`storage/`, compartilhado entre `web` e `worker`).
O dashboard do Sidekiq fica em http://localhost:3000/sidekiq, com Basic Auth via
`SIDEKIQ_WEB_USERNAME` e `SIDEKIQ_WEB_PASSWORD`. Valores de produção:
`.env.production.example`.

A cobertura é gerada automaticamente pelo SimpleCov em `coverage/`.
