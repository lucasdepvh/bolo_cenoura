# Casa do bolo de cenoura

Aplicacao Rails para catalogo, pedidos e painel administrativo da Casa do bolo de cenoura.

## Deploy no Render

O projeto foi preparado para deploy no Render com:

- `PostgreSQL` em producao via `DATABASE_URL`
- `Procfile` para subir com `puma`
- `render.yaml` para blueprint
- script de build em [bin/render-build.sh](/home/lucas/projetos/bolo_cenoura/bin/render-build.sh)
- script de post deploy em [bin/render-postdeploy.sh](/home/lucas/projetos/bolo_cenoura/bin/render-postdeploy.sh)

## O que configurar no Render

Se usar o blueprint `render.yaml`, o Render cria quase tudo sozinho. Voce so precisa confirmar:

- `RAILS_MASTER_KEY`
- `SECRET_KEY_BASE`
- `DATABASE_URL`

O `SECRET_KEY_BASE` ja pode ser gerado pelo proprio Render no blueprint.

## Fluxo recomendado

1. Suba o repositorio no GitHub.
2. No Render, escolha `New +` > `Blueprint`.
3. Aponte para o repositorio.
4. Preencha `RAILS_MASTER_KEY`.
5. Faça o deploy.

## Comandos usados pelo Render

- Build: `./bin/render-build.sh`
- Start: `bundle exec puma -C config/puma.rb`
- Post deploy: `./bin/render-postdeploy.sh`

## Seeds

Por padrao, o deploy roda `db:seed` porque `RUN_SEEDS_ON_DEPLOY=true` no `render.yaml`, o que ajuda no teste com cliente.

Se quiser desativar depois, troque para:

- `RUN_SEEDS_ON_DEPLOY=false`

## Login inicial

- Email: `admin@casadobolodecenoura.com`
- Senha: `123456`
