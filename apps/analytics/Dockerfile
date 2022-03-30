FROM ruby:3.0.2-alpine3.14 as base

RUN apk add --update --no-cache build-base

WORKDIR /tmp

COPY apps/analytics/Gemfile* /tmp

RUN bundle install --path /tmp/vendor/bundle

FROM ruby:3.0.2-alpine3.14 as backend

WORKDIR /app

COPY --from=base /tmp/vendor/bundle /tmp/vendor/bundle
COPY --from=base /usr/local/bundle/config /usr/local/bundle/config

COPY ./apps/analytics /app

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
