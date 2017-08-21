FROM ubuntu:14.04
MAINTAINER Flurin Egger <flurin@digitpaint.nl>

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get -y install build-essential zlib1g-dev libssl-dev \
               libreadline6-dev libyaml-dev git python-software-properties

ENV RUBY_DOWNLOAD_SHA256 ba5ba60e5f1aa21b4ef8e9bf35b9ddb57286cb546aac4b5a28c71f459467e507
ADD https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz /tmp/

# Install ruby
RUN \
  cd /tmp && \
  echo "$RUBY_DOWNLOAD_SHA256 *ruby-2.3.0.tar.gz" | sha256sum -c - && \
  tar -xzf ruby-2.3.0.tar.gz && \
  cd ruby-2.3.0 && \
  ./configure && \
  make && \
  make install && \
  cd .. && \
  rm -rf ruby-2.3.0 && \
  rm -f ruby-2.3.0.tar.gz

RUN gem install bundler --no-ri --no-rdoc

# Install node
ENV NODEJS_DOWNLOAD_SHA256 d7742558bb3331e41510d6e6f1f7b13c0527aecc00a63c3e05fcfd44427ff778
ADD https://nodejs.org/dist/v6.5.0/node-v6.5.0.tar.gz /tmp/

RUN \
  cd /tmp && \
  echo "$NODEJS_DOWNLOAD_SHA256 *node-v6.5.0.tar.gz" | sha256sum -c - && \
  tar xvzf node-v6.5.0.tar.gz && \
  rm -f node-v6.5.0.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  echo -e '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

RUN npm install yarn@0.19.1 -g


# Install extra dependencies
# separated from the compile dependencies for node and ruby
# to make use of docker build layers
RUN apt-get -y install zip curl
