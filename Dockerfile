FROM ruby:3.1.2-slim

RUN apt update -qq && apt install -y build-essential libpq-dev nodejs git

WORKDIR /app

COPY Gemfile Gemfile.lock .

RUN bundle install

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

COPY entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

CMD ["rails", "server", "-b", "0.0.0.0"]
