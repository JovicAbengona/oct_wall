FROM ruby:3.0.1-alpine

ENV BUNDLE_PATH /bundle

ADD . /app
WORKDIR /app

ADD Gemfile /app/
ADD Gemfile.lock /app/

RUN apk --update add --virtual build-dependencies build-base tzdata nodejs mysql-dev && \
    gem install bundler && \
    gem install debase-ruby_core_source && \
    cd /app && bundle install