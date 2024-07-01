# Use the official Ruby image
FROM ruby:2.6.0

# Set environment variables
ENV RAILS_ENV=production \
    RAILS_ROOT=/app

# Set working directory
WORKDIR $RAILS_ROOT

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    nodejs \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Bundle install with retries
RUN bundle config --global frozen 1 && \
    bundle config --global retry 5 && \
    bundle install --without development test --jobs=$(nproc) --retry=5

# Copy application code
COPY . .

# Handle mimemagic version issue
RUN bundle update mimemagic || bundle update --bundler

# Precompile assets and clean up
RUN bundle exec rails assets:precompile && \
    bundle exec rails tmp:clear && \
    bundle exec rails log:clear && \
    rm -rf node_modules tmp/cache app/assets/spec

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]