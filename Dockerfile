FROM ruby:3.3.10-slim
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential libpq-dev libyaml-dev git curl nodejs npm && \
    npm install -g yarn && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY package.json ./
RUN yarn install
COPY . .
RUN chmod +x bin/*
EXPOSE 3000
ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
