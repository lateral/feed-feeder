FROM ruby:2.7-slim-buster

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    build-essential \
    bundler \
    libmagick++-dev \
    libpq-dev \
    libcurl4-openssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /var/log/dpkg.log

COPY . /app/images
WORKDIR /app/images

RUN useradd -ms /bin/bash -d /app -u 10011 images && \
    chown -R images:images /app

RUN gem install bundler --conservative && \
    bundle check || bundle install

USER images
