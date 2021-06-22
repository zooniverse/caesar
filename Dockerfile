FROM ruby:2.6-slim-stretch
WORKDIR /app

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    nodejs \
    libjemalloc1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1

ADD ./Gemfile /app/
ADD ./Gemfile.lock /app/

ENV PORT=80
ARG RAILS_ENV=production
ENV RAILS_ENV=$RAILS_ENV
ARG REVISION=''
ENV REVISION=$REVISION

RUN bundle config --global jobs `cat /proc/cpuinfo | grep processor | wc -l | xargs -I % expr % - 1` && \
    if echo "development test" | grep -w "$RAILS_ENV"; then \
    bundle install; \
    else bundle install --without development test; fi

ADD ./ /app

RUN (echo $REVISION > ./public/commit_id.txt)
RUN (cd /app && mkdir -p tmp/pids)
RUN (cd /app && SECRET_KEY_BASE=1 bundle exec rails assets:precompile)

EXPOSE 80

CMD ["/app/docker/start-puma.sh"]
