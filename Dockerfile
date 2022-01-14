FROM ubuntu:bionic

RUN apt-get update && apt-get install -y wget

RUN apt-get indextargets
RUN set -xe && echo '#!/bin/sh' > /usr/sbin/policy-rc.d && echo 'exit 101' >> /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d && dpkg-divert --local --rename --add /sbin/initctl && cp -a /usr/sbin/policy-rc.d /sbin/initctl && sed -i 's/^exit.*/exit 0/' /sbin/initctl && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container

RUN apt-get install -yq asciidoctor bash-completion build-essential clang-tools-8 curl g++-8 git htop jq less libcurl4-gnutls-dev libgmp3-dev libssl-dev libusb-1.0-0-dev llvm-4.0 locales man-db multitail nano nginx ninja-build pkg-config python software-properties-common sudo supervisor vim wget xz-utils zlib1g-dev && update-alternatives --remove-all cc && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-8 100 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100 && update-alternatives --remove-all c++ && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-8 100 && update-alternatives --install /usr/bin/gcc++ gcc++ /usr/bin/g++-8 100 && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100 && locale-gen en_US.UTF-8 && curl -sL https://deb.nodesource.com/setup_10.x | bash - && apt-get install -yq nodejs && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* && npm i -g yarn typescript
RUN curl -LO https://cmake.org/files/v3.13/cmake-3.13.2.tar.gz && tar -xzf cmake-3.13.2.tar.gz && cd cmake-3.13.2 && ./bootstrap --prefix=/usr/local && make -j$(nproc) && make install && cd /root && rm -rf cmake-3.13.2.tar.gz cmake-3.13.2

RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers && export HOME=/user/gitpod

RUN wget https://github.com/ProtonProtocol/proton/releases/download/v2.0.5/proton_2.0.5-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./proton_2.0.5-1-ubuntu-18.04_amd64.deb

RUN wget https://github.com/eosio/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y vim build-essential libssl-dev

RUN git clone https://github.com/ProtonProtocol/proton.contracts.git /home/gitpod/proton.contracts && cd /home/gitpod/proton.contracts && git checkout v1.9.1-7 && git submodule update --init --recursive && rm -r build && mkdir build && cd /home/gitpod/proton.contracts/build && cmake -GNinja .. && ninja && mkdir /home/gitpod/contracts && cp `find . -name '*.wasm'` /home/gitpod/contracts && cd /home/gitpod && sudo chown -R gitpod /home/gitpod/contracts && sudo chgrp -R gitpod /home/gitpod/contracts && rm -rf /home/gitpod/proton.contracts

RUN echo 'alias cleosp="cleos -u https://proton.cryptolions.io"' >> ~/.bashrc
RUN echo 'alias cleospt="cleos -u https://testnet.protonchain.com"' >> ~/.bashrc
RUN echo 'alias clwu="cleos wallet unlock"' >> ~/.bashrc

RUN echo >/password && chown gitpod /password && chgrp gitpod /password && >/run/nginx.pid && chmod 666 /run/nginx.pid && chmod 666 /var/log/nginx/* && chmod 777 /var/lib/nginx /var/log/nginx
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc
RUN sudo echo "Running 'sudo' for Gitpod: success"
RUN cleos wallet create --to-console | tail -n 1 | sed 's/"//g' >/password && cleos wallet import --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
RUN rm -f /home/gitpod/.wget-hsts
RUN cd /home/gitpod/ && notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit)     && { [ -z "$notOwnedFile" ]         || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; echo $notOwnedFile; exit 1; } }

CMD tail -f /dev/null
