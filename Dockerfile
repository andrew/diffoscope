FROM ruby:3.4-alpine

RUN apk add --no-cache \
    build-base \
    git \
    yaml-dev \
    zlib-dev \
    python3 \
    py3-pip \
    openjdk17-jre-headless \
    diffoscope

RUN pip3 install --no-cache-dir --break-system-packages jsbeautifier tlsh

WORKDIR /app

COPY . .

RUN bundle install

ENTRYPOINT ["bundle", "exec", "exe/diffoscope"]
