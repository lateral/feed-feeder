FROM ruby:2.7-slim-buster

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    build-essential \
    python3-dev \
    python3-pip \
    bundler \
    libpq-dev \
    curl  \
    libxml2-dev \
    libxslt-dev \
    gcc \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /var/log/dpkg.log

RUN python3 -m pip install --upgrade pip && \
    pip install --no-cache-dir setuptools

RUN pip install --no-cache-dir -U nltk && \
    curl https://raw.githubusercontent.com/codelucas/newspaper/master/download_corpora.py | python3

COPY . /app/feedfeeder
WORKDIR /app/feedfeeder

RUN useradd -ms /bin/bash -d /app -u 10009 feedfeeder && \
    mv ~/nltk_data /app/nltk_data

RUN gem install bundler --conservative && \
    bundle check || ARCHFLAGS=' -arch x86_64' bundle install

RUN chown -R 10009:10009 /app

USER feedfeeder

RUN pip install --no-cache-dir newspaper3k goose3
