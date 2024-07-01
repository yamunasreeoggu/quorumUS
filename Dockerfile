FROM      ruby:2.6.0
RUN       apt-get update && \
          apt-get install -y nodejs npm && \
          npm install -g yarn && \
          ln -s /usr/bin/nodejs /usr/bin/node
RUN       gem install rubygems-update -v 3.2.3 && \
          update_rubygems
WORKDIR   /app
RUN       gem install bundler -v 2.4.22
COPY      Gemfile Gemfile.lock ./
RUN       bundle config set without 'development test'
RUN       bundle install --jobs "$(nproc)" --retry 5
COPY      . .
RUN       bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java && \
          bundle install
RUN       ./bin/setup
EXPOSE    3000
CMD       ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
