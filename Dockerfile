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
COPY Gemfile ./
COPY Gemfile.d/app.rb ./Gemfile.d/
COPY config/canvas_rails5.rb config/
RUN bundle install
COPY package.json \
     .npmrc \
     .nvmrc \
     ./
RUN npm install

COPY . ./
RUN bundle update
RUN mkdir -p log \
    tmp \
    public/javascripts/client_apps \
    public/dist \
    public/assets && \
    chown -R docker:docker . /home/docker && \
    touch mkmf.log .listen_test && \
    chmod 777 mkmf.log .listen_test && \
    chown -R docker:9999 . && \
    chmod 775 gems/canvas_i18nliner && \
    chmod 775 . log tmp gems/selinimum gems/canvas_i18nliner && \
    chmod 664 ./app/stylesheets/_brand_variables.scss

USER docker
RUN bundle exec rake canvas:compile_assets
