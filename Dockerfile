FROM ubuntu:14.04

# Replace shell with bash so we can source files
# RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV RAILS_ENV production


# Dependency and Node installation
# RUN apt-get update -qq && apt-get install -y build-essential software-properties-common libpq-dev ruby-dev zlib1g-dev libxml2-dev libxslt1-dev libhttpclient-ruby imagemagick libxmlsec1-dev python-software-properties libpq-dev libpqxx-dev libglib2.0 libssl-dev

# add nodejs and recommended ruby repos
RUN sudo apt-get update \
    && sudo apt-get -y install curl software-properties-common \
    && sudo add-apt-repository -y ppa:brightbox/ruby-ng \
    && sudo apt-get update \
    && sudo apt-get install -y ruby2.3 ruby2.3-dev supervisor redis-server \
        zlib1g-dev libxml2-dev libxslt1-dev libsqlite3-dev postgresql \
        postgresql-contrib libpq-dev libxmlsec1-dev curl make g++ git

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

RUN sudo apt-get clean && sudo rm -Rf /var/cache/apt

# Set the locale to avoid active_model_serializers bundler install failure
RUN sudo locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Workfolder creation and setup
RUN mkdir /var/canvas
WORKDIR /var/canvas
# File Copy of full canvas code
COPY . /var/canvas

# Gem installation
RUN sudo gem install bundler --version 1.13.6
RUN bundle install --without mysql --path vendor/bundle

# Copy of configuration files

# Database config requires ENV variables
# POSTGRES_USER
# POSTGRES_PASSWORD
# DB_HOST - Hostname for the database server
COPY custom_docker/database.yml config/database.yml
# Domain config requires ENV variables
# DOMAIN - eg: subdomain.domain.com

# Outgoing mail configured to use 'test' method
COPY custom_docker/outgoing_mail.yml config/outgoing_mail.yml

COPY custom_docker/domain.yml config/domain.yml
# Security config requires ENV variables
# ENCRYPTION_KEY
COPY custom_docker/security.yml config/security.yml

COPY custom_docker/cache_store.yml config/cache_store.yml

# Initial database setup for production
# Requires preset ENV variables
# CANVAS_LMS_ADMIN_EMAIL
# CANVAS_LMS_ADMIN_PASSWORD
# CANVAS_LMS_ACCOUNT_NAME
# CANVAS_LMS_STATS_COLLECTION
## Moved to docker-compose.setup.yml
##RUN RAILS_ENV=production bundle exec rake db:initial_setup

## User access and file security relating to users
# Create a Canvas user
RUN sudo adduser --disabled-password --gecos canvas canvasuser

# Setup assets folder and ownership to new user
RUN mkdir -p log tmp/pids public/assets public/stylesheets/compiled
RUN touch Gemfile.lock
# RUN chown -R canvasuser config/environment.rb log tmp public/assets \
#         public/stylesheets/compiled Gemfile.lock config.ru

# npm
RUN npm install
RUN npm install i18nliner
# Compile assets
## Moved to docker-compose.setup.yml
# RUN RAILS_ENV=production bundle exec rake canvas:compile_assets

# Restrict config files to canvasuser
# RUN chown canvasuser config/*.yml
# RUN chmod 400 config/*.yml

RUN mkdir public/dist
