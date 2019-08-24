FROM quay.io/spivegin/caddy_only AS build-env-go110

FROM quay.io/spivegin/nodejsyarn:latest

RUN echo "deb https://apache.bintray.com/couchdb-deb stretch main" > /etc/apt/sources.list.d/couchdb.list &&\
    apt-get update && apt-get -y upgrade &&\
    # apt install -y couchdb --allow-unauthenticated &&\
    mkdir -p /opt/tricll/charactercreator &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ADD . /opt/tricll/charactercreator/
RUN mkdir /opt/bin 
COPY --from=build-env-go110 /opt/bin/caddy /opt/bin/caddy


WORKDIR /opt/tricll/charactercreator/

RUN npm install gulp-cli -g &&\
    npm install gulp -D &&\
    npm install &&\
    mkdir -p /opt/tlm

ENV DINIT=1.2.2 

ADD https://raw.githubusercontent.com/adbegon/pub/master/AdfreeZoneSSL.crt /usr/local/share/ca-certificates/
ADD https://github.com/Yelp/dumb-init/releases/download/v${DINIT}/dumb-init_${DINIT}_amd64.deb /tmp/dumb-init_amd64.deb
ADD files/bash/caddy_entry.sh /opt/bin/entry.sh
ADD files/caddy/Caddyfile /opt/tlm/Caddyfile
RUN update-ca-certificates --verbose &&\
    chmod +x /opt/bin/caddy &&\
    ln -s /opt/bin/caddy /bin/caddy &&\
    chmod +x /opt/bin/entry.sh &&\
    dpkg -i /tmp/dumb-init_amd64.deb &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

EXPOSE 80
CMD [ "/opt/bin/entry.sh" ]

