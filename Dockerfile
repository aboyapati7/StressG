FROM ubuntu:18.04

ENV COORDINATOR_DIR /root/downloads/stressgrid/coordinator/
ENV GENERATOR_DIR /root/downloads/stressgrid/generator/

RUN apt-get update && apt-get install -y wget gnupg2 curl git
RUN wget -q -O - https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | apt-key add -
RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && dpkg -i erlang-solutions_2.0_all.deb
RUN echo "deb https://packages.erlang-solutions.com/ubuntu bionic contrib" | tee /etc/apt/sources.list.d/rabbitmq.list
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update && apt-get install -y \
#    erlang \
    esl-erlang \
    elixir \
    build-essential \
    manpages-dev \
    nodejs

RUN apt-get install -y zlib1g-dev
RUN cd && mkdir downloads && cd downloads && \
    git clone https://gitlab.com/stressgrid/stressgrid.git && \
    cd stressgrid/coordinator/management/ && npm install && npm run build-css && npm run build && \
    cd .. && mix local.hex --force && mix local.rebar --force && \
    HEX_HTTP_CONCURRENCY=1 HEX_HTTP_TIMEOUT=120 MIX_ENV=prod mix deps.get -y && MIX_ENV=prod mix release

RUN cd $GENERATOR_DIR && MIX_ENV=prod mix deps.get -y && MIX_ENV=prod mix release





