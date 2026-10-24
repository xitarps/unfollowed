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

O botão **Sign in** faz login via OIDC no Keycloak (realm `unfollowed`, importado de `docker/keycloak/realm/unfollowed-realm.json` com `--import-realm`), e o Keycloak autentica com o GitHub. `/unfollowers` só é acessível para usuários autenticados.

1. Crie um **GitHub OAuth App** (GitHub → Settings → Developer settings → OAuth Apps):
   - Homepage URL: `APP_URL` (ex.: `https://unfollowed.com.br`)
   - Authorization callback URL: `<KC_HOSTNAME>/realms/unfollowed/broker/github/endpoint` (ex.: `https://auth.unfollowed.com.br/realms/unfollowed/broker/github/endpoint`)
2. No `.env`, preencha `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `OIDC_CLIENT_SECRET` (qualquer segredo forte) e use `OIDC_IDP_HINT=github`.
3. Suba o stack. O realm só é importado na primeira vez; mudanças posteriores devem ser feitas no console do Keycloak.

Em desenvolvimento, deixe `OIDC_IDP_HINT` vazio para ver a tela de login do Keycloak e entrar com um usuário criado no console (http://localhost:8080, realm `unfollowed`).

### Unfollowers (quem você segue e não te segue de volta)

`/unfollowers` lista, com paginação, as contas que você segue e que não seguem você de volta, com botão **Unfollow** por conta e **Unfollow all** no topo (executado em background pelo Sidekiq, com pausa de 1s entre as chamadas por causa dos limites do GitHub).

O token do GitHub não passa pelo navegador: o Keycloak o guarda (broker) e o Rails o busca em `/realms/unfollowed/broker/github/token` logo após o login. A lógica fica em `app/services/github/` (orquestradores + `FetcherService`s + `Providers`, sobre `ServiceInterface`).

Requisitos no Keycloak (já vêm no `unfollowed-realm.json`; em um realm criado manualmente, ajuste em Identity providers → GitHub):
- **Store tokens** e **Stored tokens readable**: ligados
- **Default scopes**: `user:email read:user user:follow`

Usuários que já tinham feito login antes dessa mudança precisam ser apagados (Users → Delete) e entrar de novo, para o Keycloak guardar o token e conceder a role `read-token`. No OAuth App do GitHub, deixe **Expire user access tokens** desmarcado: o Keycloak não renova o token do GitHub.

### Produção (unfollowed.com.br)

1. Crie registros DNS `A` para `unfollowed.com.br`, `www` e `auth` apontando para o servidor, e libere as portas 80 e 443.
2. `cp .env.production.example .env`, preencha `RAILS_MASTER_KEY`, `ACME_EMAIL` e troque todos os `change-me`.
3. `docker compose --profile production up -d --build`

#### Subir com a VPS (systemd)

O arquivo [system_lib/unfollowed_app.service](system_lib/unfollowed_app.service) sobe e derruba toda a stack (`docker compose --profile production`).

```bash
# 1. Clone o projeto (o service assume `~/app/unfollowed`) e crie o .env
mkdir -p ~/app && git clone https://github.com/xitarps/unfollowed.git ~/app/unfollowed
cd ~/app/unfollowed && cp .env.production.example .env   # preencha os valores

# 2. Edite `User=` em system_lib/unfollowed_app.service para o seu usuario da VPS
#    (precisa estar no grupo docker: sudo usermod -aG docker $USER)
#    Link simbolico para o systemd (as alteracoes via git pull valem sem copiar)
sudo ln -s "$HOME/app/unfollowed/system_lib/unfollowed_app.service" /etc/systemd/system/unfollowed_app.service
sudo systemctl daemon-reload

# 3. Use
sudo systemctl start unfollowed_app     # sobe (build + up -d)
sudo systemctl enable unfollowed_app    # sobe junto com a VPS
sudo systemctl disable unfollowed_app   # nao sobe mais com a VPS
sudo systemctl stop unfollowed_app      # derruba os containers
sudo systemctl reload unfollowed_app    # rebuild apos git pull
systemctl status unfollowed_app
```

`WorkingDirectory=~` resolve para a home do `User=`. Se clonar em outro diretorio, altere `WorkingDirectory` (caminho absoluto) no service e rode `sudo systemctl daemon-reload`. O caminho do `docker` pode ser conferido com `which docker`. O Docker precisa estar habilitado (`sudo systemctl enable docker`).

O Keycloak fica em https://auth.unfollowed.com.br; com `KEYCLOAK_BIND_ADDRESS=127.0.0.1` a porta 8080 não é exposta externamente. O TLS termina no Caddy, e `FORCE_SSL=true` ativa `assume_ssl`/`force_ssl` no Rails.

O Rails usa PostgreSQL (`DB_*` no `.env`); o `web` executa `db:prepare` ao iniciar. Em produção, os bancos de cache e cable usam o nome de `DB_NAME` com sufixo `_cache` e `_cable`.
O dashboard do Sidekiq fica em http://localhost:3000/sidekiq, com Basic Auth via
`SIDEKIQ_WEB_USERNAME` e `SIDEKIQ_WEB_PASSWORD`. Valores de produção:
`.env.production.example`.

A cobertura é gerada automaticamente pelo SimpleCov em `coverage/`.
