# See doc/docker/README.md or https://github.com/instructure/canvas-lms/tree/master/doc/docker
FROM instructure/ruby-passenger:2.3

ENV APP_HOME /usr/src/app/
ENV RAILS_ENV "production"
ENV NGINX_MAX_UPLOAD_SIZE 10g

USER root
WORKDIR /root
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -\
  && apt-get update -qq \
  && apt-get install -qqy \
       nodejs \
       postgresql-client \
       libxmlsec1-dev \
       unzip \
       fontforge \
       python-lxml \
  && npm install -g gulp \
  && rm -rf /var/lib/apt/lists/*\
  && mkdir -p /home/docker/.gem/ruby/$RUBY_MAJOR.0

# We will need sfnt2woff in order to build fonts
RUN if [ -e /var/lib/gems/$RUBY_MAJOR.0/gems/bundler-* ]; then BUNDLER_INSTALL="-i /var/lib/gems/$RUBY_MAJOR.0"; fi \
  && curl -O  https://people-mozilla.org/~jkew/woff/woff-code-latest.zip \
  && unzip woff-code-latest.zip \
  && make \
  && cp sfnt2woff /usr/local/bin \
  && gem uninstall --all --ignore-dependencies --force $BUNDLER_INSTALL bundler \
  && gem install bundler --no-document -v 1.12.5 \
  && find $GEM_HOME ! -user docker | xargs chown docker:docker

WORKDIR $APP_HOME
USER root
COPY Gemfile      ${APP_HOME}
COPY Gemfile.d    ${APP_HOME}Gemfile.d
COPY config       ${APP_HOME}config
COPY gems         ${APP_HOME}gems
RUN bundle install
COPY package.json ${APP_HOME}
RUN npm install
COPY . $APP_HOME
RUN mkdir -p log \
            tmp \
            public/javascripts/client_apps \
            public/dist \
            public/assets \
  && chown -R docker:docker ${APP_HOME} /home/docker


RUN touch mkmf.log .listen_test
RUN chmod 777 mkmf.log .listen_test
RUN chown -R docker:9999 .
RUN chmod 775 gems/canvas_i18nliner
RUN chmod 775 . log tmp gems/selinimum gems/canvas_i18nliner
RUN chmod 664 ./app/stylesheets/_brand_variables.scss

USER docker
RUN bundle exec rake canvas:compile_assets

COPY custom_docker/database.yml config/database.yml
COPY custom_docker/outgoing_mail.yml config/outgoing_mail.yml
COPY custom_docker/domain.yml config/domain.yml
COPY custom_docker/security.yml config/security.yml
COPY custom_docker/cache_store.yml config/cache_store.yml
COPY custom_docker/delayed_jobs.yml config/delayed_jobs.yml
COPY custom_docker/unicorn.rb config/unicorn.rb
COPY custom_docker/wait-for-it.sh wait-for-it.sh
COPY custom_docker/start_canvas.rb start_canvas.rb
