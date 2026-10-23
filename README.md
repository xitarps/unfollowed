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
- `db`: PostgreSQL 17, compartilhado pela aplicação e pelo Keycloak (o banco `keycloak` é criado por `docker/postgres/init-keycloak-db.sh` na primeira inicialização do volume)
- `keycloak`: Keycloak em http://localhost:8080. O modo vem de `KEYCLOAK_COMMAND` no `.env` (`start-dev` em desenvolvimento, `start` em produção), via `docker/keycloak/entrypoint.sh`; admin em `KC_BOOTSTRAP_ADMIN_*`, dados no PostgreSQL
- `caddy` (profile `production`): proxy reverso com TLS automático (Let's Encrypt) para `APP_DOMAIN` e `KEYCLOAK_DOMAIN`

### Produção (unfollowed.com.br)

1. Crie registros DNS `A` para `unfollowed.com.br`, `www` e `auth` apontando para o servidor, e libere as portas 80 e 443.
2. `cp .env.production.example .env`, preencha `RAILS_MASTER_KEY`, `ACME_EMAIL` e troque todos os `change-me`.
3. `docker compose --profile production up -d --build`

O Keycloak fica em https://auth.unfollowed.com.br; com `KEYCLOAK_BIND_ADDRESS=127.0.0.1` a porta 8080 não é exposta externamente. O TLS termina no Caddy, e `FORCE_SSL=true` ativa `assume_ssl`/`force_ssl` no Rails.

O Rails usa PostgreSQL (`DB_*` no `.env`); o `web` executa `db:prepare` ao iniciar. Em produção, os bancos de cache e cable usam o nome de `DB_NAME` com sufixo `_cache` e `_cable`.
O dashboard do Sidekiq fica em http://localhost:3000/sidekiq, com Basic Auth via
`SIDEKIQ_WEB_USERNAME` e `SIDEKIQ_WEB_PASSWORD`. Valores de produção:
`.env.production.example`.

A cobertura é gerada automaticamente pelo SimpleCov em `coverage/`.
