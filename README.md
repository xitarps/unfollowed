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

### Autenticação (Keycloak + GitHub)

O botão **Sign in** faz login via OIDC no Keycloak (realm `unfollowed`, importado de `docker/keycloak/realm/unfollowed-realm.json` com `--import-realm`), e o Keycloak autentica com o GitHub. `/followers` só é acessível para usuários autenticados.

1. Crie um **GitHub OAuth App** (GitHub → Settings → Developer settings → OAuth Apps):
   - Homepage URL: `APP_URL` (ex.: `https://unfollowed.com.br`)
   - Authorization callback URL: `<KC_HOSTNAME>/realms/unfollowed/broker/github/endpoint` (ex.: `https://auth.unfollowed.com.br/realms/unfollowed/broker/github/endpoint`)
2. No `.env`, preencha `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `OIDC_CLIENT_SECRET` (qualquer segredo forte) e use `OIDC_IDP_HINT=github`.
3. Suba o stack. O realm só é importado na primeira vez; mudanças posteriores devem ser feitas no console do Keycloak.

Em desenvolvimento, deixe `OIDC_IDP_HINT` vazio para ver a tela de login do Keycloak e entrar com um usuário criado no console (http://localhost:8080, realm `unfollowed`).

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
