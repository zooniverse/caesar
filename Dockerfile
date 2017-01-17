FROM ruby:2.3
WORKDIR /app
ARG RAILS_ENV

RUN apt-get update && \
    apt-get install --no-install-recommends -y git curl supervisor libpq-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir config && curl "https://ip-ranges.amazonaws.com/ip-ranges.json" > config/aws_ips.json

ADD ./Gemfile /app/
ADD ./Gemfile.lock /app/

RUN if [ "$RAILS_ENV" = "development" ]; then bundle install; else bundle install --without development test; fi

ADD ./docker/supervisord.conf /etc/supervisor/conf.d/caesar.conf
ADD ./ /app

RUN (cd /app && git log --format="%H" -n 1 > commit_id.txt)

EXPOSE 81

CMD ["bash", "/app/docker/start.sh"]