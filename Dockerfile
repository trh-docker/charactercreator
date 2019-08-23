FROM quay.io/spivegin/golang:v1.11.4 AS build-env-go110
WORKDIR /opt/src/src/github.com/mholt
ADD files/caddy_mods/caddyhttp.go.txt /tmp/caddyhttp.go
ADD files/caddy_mods/run.go.txt /tmp/run.go
ADD files/caddy_mods/go.mod.txt /tmp/go.mod

RUN apt-get update && apt-get install -y gcc &&\
    go get github.com/caddyserver/builds &&\
    go get github.com/mholt/caddy

ENV GO111MODULE=on
RUN cd caddy &&\
    cp /tmp/run.go ${GOPATH}/src/github.com/mholt/caddy/caddy/caddymain/ &&\
    cp /tmp/caddyhttp.go ${GOPATH}/src/github.com/mholt/caddy/caddyhttp/ &&\
    cp /tmp/go.mod ${GOPATH}/src/github.com/mholt/caddy/go.mod &&\
    go mod tidy && go mod vendor
ENV GO111MODULE=off
RUN git clone https://github.com/mholt/certmagic.git
RUN cd caddy/caddy && go run build.go

FROM quay.io/spivegin/nodejsyarn:latest

RUN echo "deb https://apache.bintray.com/couchdb-deb stretch main" > /etc/apt/sources.list.d/couchdb.list &&\
    apt-get update && apt-get -y upgrade &&\
    # apt install -y couchdb --allow-unauthenticated &&\
    mkdir -p /opt/tricll/charactercreator &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ADD . /opt/tricll/charactercreator/
RUN mkdir /opt/bin 
COPY --from=build-env-go110 /opt/src/src/github.com/mholt/caddy/caddy/caddy /opt/bin/caddy


WORKDIR /opt/tricll/charactercreator/

RUN yarn install && mkdir -p /opt/tlm

ADD https://raw.githubusercontent.com/adbegon/pub/master/AdfreeZoneSSL.crt /usr/local/share/ca-certificates/
ADD files/bash/caddy_entry.sh /opt/bin/entry.sh
ADD files/caddy/Caddyfile /opt/tlm/Caddyfile
RUN update-ca-certificates --verbose &&\
    chmod +x /opt/bin/caddy &&\
    ln -s /opt/bin/caddy /bin/caddy &&\
    chmod +x /opt/bin/entry.sh &&\
    dpkg -i /tmp/dumb-init_amd64.deb && \
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

EXPOSE 80
CMD [ "/bin/entry.sh" ]
