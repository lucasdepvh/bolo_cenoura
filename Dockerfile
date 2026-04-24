FROM ruby:3.1-slim-bookworm

RUN apt update -qq && apt install -y build-essential libpq-dev nodejs git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

RUN DATABASE_URL=postgresql://dummy SECRET_KEY_BASE=1 bundle exec rails assets:precompile

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

CMD ["/usr/bin/entrypoint.sh"]
