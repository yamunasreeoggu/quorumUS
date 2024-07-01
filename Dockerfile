FROM centos/ruby-26-centos7
USER root

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Base.repo
RUN sed -i 's/#baseurl/baseurl/g' /etc/yum.repos.d/CentOS-Base.repo
RUN sed -i 's/mirror.centos.org/your-mirror-url/g' /etc/yum.repos.d/CentOS-Base.repo

# Update packages and install necessary tools
RUN yum update -y
RUN yum install -y gcc-c++ make libpq-devel nodejs

# Install Rubygems update and update Rubygems
RUN gem install rubygems-update -v 3.2.3
RUN update_rubygems

WORKDIR /app

# Install Bundler
RUN gem install bundler -v 2.4.22

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Configure Bundler and install dependencies
RUN bundle config set without 'development test'
RUN bundle update mimemagic || bundle update --bundler
RUN bundle install

# Copy the rest of the application code
COPY . .

# Remove mimemagic entry from Gemfile.lock
RUN sed -i '/mimemagic/d' Gemfile.lock
RUN bundle install

# Setup the application
RUN ./bin/setup

# Expose port 3000
EXPOSE 3000

# Command to start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
