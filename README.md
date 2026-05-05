# Casa do bolo de cenoura

Aplicacao Rails para catalogo, pedidos e painel administrativo da Casa do bolo de cenoura.

## Banco de dados

O projeto usa `SQLite3` em todos os ambientes:

- desenvolvimento: `db/development.sqlite3`
- teste: `db/test.sqlite3`
- producao: `db/production.sqlite3`

Nao e necessario configurar PostgreSQL nem `DATABASE_URL`.

## Deploy no Render

O projeto esta preparado para deploy no Render com:

- `SQLite3` em producao
- `render.yaml` para blueprint
- script de build em [bin/render-build.sh](/home/lucas/projetos/bolo_cenoura/bin/render-build.sh)
- script de post deploy em [bin/render-postdeploy.sh](/home/lucas/projetos/bolo_cenoura/bin/render-postdeploy.sh)

Se usar o blueprint `render.yaml`, voce precisa confirmar:

- `RAILS_MASTER_KEY`
- `SECRET_KEY_BASE`

O `SECRET_KEY_BASE` ja pode ser gerado pelo proprio Render no blueprint.

## Fluxo recomendado

1. Suba o repositorio no GitHub.
2. No Render, escolha `New +` > `Blueprint`.
3. Aponte para o repositorio.
4. Preencha `RAILS_MASTER_KEY`.
5. Faca o deploy.

## Comandos usados pelo Render

- Build: `./bin/render-build.sh`
- Start: `bundle exec puma -C config/puma.rb`
- Post deploy: `./bin/render-postdeploy.sh`

## Deploy no Railway

No Railway, voce precisa somente do servico da aplicacao Rails. Nao precisa criar um servico PostgreSQL.

Configure as variaveis da aplicacao:

- `RAILS_ENV=production`
- `RAILS_MASTER_KEY=...`
- `SECRET_KEY_BASE=...`

O script [entrypoint.sh](/home/lucas/projetos/bolo_cenoura/entrypoint.sh) faz isto:

- roda `bundle exec rails db:migrate`
- sobe o servidor com `puma`

## Seeds

Por padrao, o deploy roda `db:seed` porque `RUN_SEEDS_ON_DEPLOY=true` no `render.yaml`, o que ajuda no teste com cliente.

Se quiser desativar depois, troque para:

- `RUN_SEEDS_ON_DEPLOY=false`

## Login inicial

- Email: `admin@casadobolodecenoura.com`
- Senha: `123456`
