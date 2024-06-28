FROM      ruby:2.6.0
RUN       gem install rubygems-update -v 3.2.3
RUN       update_rubygems
ENV       RAILS_ENV=production
WORKDIR   /app
RUN       gem install bundler -v 2.4.22
COPY      Gemfile Gemfile.lock ./
RUN       bundle config set without 'development test'
RUN       bundle install
COPY      . .
RUN       ./bin/setup
EXPOSE    3000
CMD       ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
