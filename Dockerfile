# Use the official Ruby image from Docker Hub based on CentOS
FROM centos:8

# Install necessary dependencies
RUN yum update -y && \
    yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel \
                   libyaml-devel libffi-devel openssl-devel make \
                   bzip2 autoconf automake libtool bison sqlite-devel

# Install Ruby 2.6.0
RUN curl -fsSL https://github.com/ruby/ruby/archive/v2.6.0.tar.gz | tar -xz && \
    cd ruby-2.6.0/ && \
    autoconf && \
    ./configure --disable-install-doc && \
    make && \
    make install && \
    cd .. && \
    rm -rf ruby-2.6.0

# Install rubygems-update and update RubyGems
RUN gem install rubygems-update -v 3.2.3 && \
    update_rubygems

# Set working directory
WORKDIR /app

# Install Bundler 2.4.22
RUN gem install bundler -v 2.4.22

# Copy Gemfiles
COPY Gemfile Gemfile.lock ./

# Configure Bundler
RUN bundle config set without 'development test'

# Update mimemagic gem or Bundler itself
RUN bundle update mimemagic || bundle update --bundler

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Remove mimemagic from Gemfile.lock (if present)
RUN sed -i '/mimemagic/d' Gemfile.lock

# Install dependencies again (if Gemfile.lock changed)
RUN bundle install

# Run setup script
RUN ./bin/setup

# Expose port 3000
EXPOSE 3000

# Define the command to run the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

