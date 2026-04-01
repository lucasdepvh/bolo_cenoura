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
- Start: `./entrypoint.sh bundle exec puma -C config/puma.rb`
- Post deploy: `./bin/render-postdeploy.sh`

## Deploy no Railway

### 1. Criar os servicos

No Railway, voce precisa ter:

- 1 servico da aplicacao Rails
- 1 servico PostgreSQL

Se o PostgreSQL ja foi criado, o proximo passo importante e conectar a app a ele pela variavel `DATABASE_URL`.

### 2. Configurar o Start Command

No servico da aplicacao, abra:

- `Settings` > `Start Command`

Use este comando:

- `./entrypoint.sh bundle exec puma -C config/puma.rb`

O script [entrypoint.sh](/home/lucas/projetos/bolo_cenoura/entrypoint.sh) faz isto:

- roda `bundle exec rails db:migrate`
- sobe o servidor com `puma`

### 3. Configurar as variaveis da aplicacao

No servico da app, abra:

- `Variables`

Confirme que estas variaveis existem:

- `RAILS_ENV=production`
- `RAILS_MASTER_KEY=...`
- `SECRET_KEY_BASE=...`
- `DATABASE_URL=...`

O ponto mais importante aqui e o `DATABASE_URL`.

Este projeto usa essa configuracao em [config/database.yml](/home/lucas/projetos/bolo_cenoura/config/database.yml):

```yml
production:
  adapter: postgresql
  url: <%= ENV["DATABASE_URL"] %>
```

Se `DATABASE_URL` estiver vazio ou ausente, a app tenta usar PostgreSQL local e aparece o erro:

`could not connect to server ... /var/run/postgresql/.s.PGSQL.5432`

### 4. Como ligar o banco na app

Se voce ja criou o PostgreSQL no Railway, faca assim:

1. Abra o servico da aplicacao.
2. Va em `Variables`.
3. Verifique se existe a variavel `DATABASE_URL`.
4. Se nao existir, adicione uma nova variavel chamada `DATABASE_URL`.
5. No valor, use a referencia/valor da conexao do servico PostgreSQL do Railway.

Em resumo: a app Rails precisa receber a URL de conexao do banco criado no Railway.

### 5. Fazer o deploy novamente

Depois de salvar as variaveis:

1. Va em `Deployments`.
2. Clique em `Redeploy`.

Na subida, o Railway vai executar:

- `./entrypoint.sh bundle exec puma -C config/puma.rb`

E o script vai tentar:

- migrar o banco
- iniciar a aplicacao

### 6. Se ainda der erro

Confira estes pontos:

- o `DATABASE_URL` esta realmente preenchido no servico da app
- o `RAILS_MASTER_KEY` esta correto
- voce fez o redeploy depois de salvar as variaveis
- o banco PostgreSQL e a app estao no mesmo projeto do Railway

## Seeds

Por padrao, o deploy roda `db:seed` porque `RUN_SEEDS_ON_DEPLOY=true` no `render.yaml`, o que ajuda no teste com cliente.

Se quiser desativar depois, troque para:

- `RUN_SEEDS_ON_DEPLOY=false`

## Login inicial

- Email: `admin@casadobolodecenoura.com`
- Senha: `123456`
