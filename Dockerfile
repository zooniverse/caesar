FROM ruby:2.5-stretch
WORKDIR /app
ENV PORT=80
ARG RAILS_ENV=production

RUN apt-get update && \
    curl https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install --no-install-recommends -y git curl libpq-dev nodejs libjemalloc1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1

RUN mkdir config && curl "https://ip-ranges.amazonaws.com/ip-ranges.json" > config/aws_ips.json

ADD ./Gemfile /app/
ADD ./Gemfile.lock /app/

RUN if [ "$RAILS_ENV" = "development" ]; then bundle install; else bundle install --without development test; fi

ADD ./ /app

RUN (cd /app && git log --format="%H" -n 1 > ./public/commit_id.txt)
RUN (cd /app && mkdir -p tmp/pids)
RUN (cd /app && SECRET_KEY_BASE=1 bundle exec rails assets:precompile)

RUN mkdir -p log && \
    ln -sf /dev/stdout log/production.log && \
    ln -sf /dev/stdout log/staging.log && \
    ln -sf /dev/stdout log/sidekiq.log && \
    ln -sf /dev/stdout log/newrelic_agent.log

EXPOSE 80

CMD ["/app/docker/start-puma.sh"]
