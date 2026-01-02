FROM ruby:3.4

RUN apt-get update && apt-get install -y \
    python3-pip \
    diffoscope \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN bundle install

ENTRYPOINT ["bundle", "exec", "exe/diffoscope"]
