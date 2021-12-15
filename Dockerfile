FROM ubuntu:bionic

RUN apt-get update && apt-get install -y wget

RUN wget https://github.com/eosio/eos/releases/download/v2.0.7/eosio_2.0.7-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio_2.0.7-1-ubuntu-18.04_amd64.deb

RUN wget https://github.com/eosio/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb

RUN apt-get install -y vim build-essential libssl-dev cmake

RUN echo 'alias cleosp="cleos -u https://proton.cryptolions.io"' >> ~/.bashrc
RUN echo 'alias cleospt="cleos -u https://testnet.protonchain.com"' >> ~/.bashrc
RUN echo 'alias clwu="cleos wallet unlock"' >> ~/.bashrc

CMD tail -f /dev/null