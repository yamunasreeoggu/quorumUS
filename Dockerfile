FROM ruby:2.6.0

# Update system dependencies and install necessary packages
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs

# Install specific version of rubygems-update
RUN gem install rubygems-update -v 3.2.3 && \
    update_rubygems

# Set the working directory
WORKDIR /app

# Install bundler
RUN gem install bundler -v 2.4.22

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Configure Bundler and install dependencies
RUN bundle config set without 'development test' && \
    bundle update --bundler && \
    bundle install

# Copy application code
COPY . .

# Remove mimemagic from Gemfile.lock
RUN sed -i '/mimemagic/d' Gemfile.lock && \
    bundle install

# Run setup script or necessary commands
RUN ./bin/setup

# Expose port
EXPOSE 3000

# Define command to run the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
