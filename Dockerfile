FROM      ruby:2.6.0
RUN       dnf update -qq && \
          dnf install -y build-essential libpq-dev nodejs
RUN       gem install rubygems-update -v 3.2.3
RUN       update_rubygems
WORKDIR   /app
RUN       gem install bundler -v 2.4.22
COPY      Gemfile Gemfile.lock ./
RUN       bundle config set without 'development test'
RUN       bundle update mimemagic || bundle update --bundler
RUN       bundle install
COPY      . .
RUN       sed -i '/mimemagic/d' Gemfile.lock
RUN       bundle install
RUN       ./bin/setup
EXPOSE    3000
CMD       ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]