FROM ubuntu:bionic

RUN apt-get update && apt-get install -y wget

RUN apt-get indextargets
RUN set -xe && echo '#!/bin/sh' > /usr/sbin/policy-rc.d && echo 'exit 101' >> /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d && dpkg-divert --local --rename --add /sbin/initctl && cp -a /usr/sbin/policy-rc.d /sbin/initctl && sed -i 's/^exit.*/exit 0/' /sbin/initctl && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container

RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

RUN wget https://github.com/eosio/eos/releases/download/v2.0.7/eosio_2.0.7-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio_2.0.7-1-ubuntu-18.04_amd64.deb

RUN wget https://github.com/eosio/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb

RUN cd /home/gitpod/
RUN git clone https://github.com/ProtonProtocol/proton.contracts.git && cd /home/gitpod/proton.contracts && git checkout v1.9.1-7 && git submodule update --init --recursive && rm -r build && mkdir build && cd /home/gitpod/proton.contracts/build && cmake -GNinja .. && ninja && mkdir /home/gitpod/contracts && cp `find . -name '*.wasm'` /home/gitpod/contracts && cd /home/gitpod && rm -rf /home/gitpod/eosio.contracts

RUN apt-get install -y vim build-essential libssl-dev cmake

RUN echo 'alias cleosp="cleos -u https://proton.cryptolions.io"' >> ~/.bashrc
RUN echo 'alias cleospt="cleos -u https://testnet.protonchain.com"' >> ~/.bashrc
RUN echo 'alias clwu="cleos wallet unlock"' >> ~/.bashrc

RUN echo >/password && chown gitpod /password && chgrp gitpod /password && >/run/nginx.pid && chmod 666 /run/nginx.pid && chmod 666 /var/log/nginx/* && chmod 777 /var/lib/nginx /var/log/nginx
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc
RUN sudo echo "Running 'sudo' for Gitpod: success"
RUN cleos wallet create --to-console | tail -n 1 | sed 's/"//g' >/password && cleos wallet import --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
RUN echo '\n unlock-timeout = 31536000 \n' >$HOME/proton-wallet/config.ini
RUN rm -f $HOME/.wget-hsts
RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit)     && { [ -z "$notOwnedFile" ]         || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }

CMD tail -f /dev/null
