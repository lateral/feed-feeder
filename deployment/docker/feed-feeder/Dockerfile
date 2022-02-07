FROM ruby:2.7-slim-buster

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    build-essential \
    bundler \
    libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /var/log/dpkg.log

COPY . /app/feedfeeder
WORKDIR /app/feedfeeder

RUN useradd -ms /bin/bash -d /app -u 10009 feedfeeder && \
    chown -R feedfeeder:feedfeeder /app

RUN gem install bundler --conservative && \
    bundle check || ARCHFLAGS=' -arch x86_64' bundle install

USER feedfeeder
