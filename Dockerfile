# Use the official Ruby image from Docker Hub
FROM ruby:2.6.0

# Install essential packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install specific version of rubygems-update and update RubyGems
RUN gem install rubygems-update -v 3.2.3
RUN update_rubygems

# Set working directory for the application
WORKDIR /app

# Install Bundler and dependencies
RUN gem install bundler -v 2.4.22
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test'
RUN bundle install --jobs "$(nproc)" --retry 5

# Remove mimemagic from Gemfile.lock if present (if needed)
# RUN sed -i '/mimemagic/d' Gemfile.lock

# Copy the application code
COPY . ./

# Setup the application (run migrations, etc.)
RUN bundle exec rails db:prepare

# Expose port 3000
EXPOSE 3000

# Command to run the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
