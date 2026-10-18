FROM ruby:3.2.1

RUN apt-get update && apt-get install -y \
  build-essential \
  nodejs \
  libpq-dev \
  postgresql-client \
  vim
  

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
COPY . ./

RUN gem install sassc:2.4.0
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 3000

RUN bundle install
