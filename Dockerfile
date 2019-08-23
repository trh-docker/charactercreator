FROM quay.io/spivegin/nodejsyarn:latest

RUN echo "deb https://apache.bintray.com/couchdb-deb stretch main" > /etc/apt/sources.list.d/couchdb.list &&\
    apt-get update && apt-get -y upgrade &&\
    apt install -y couchdb &&\
    mkdir -p /opt/tricll/charactercreator &&\
    apt-get autoclean && apt-get autoremove &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ADD . /opt/tricll/charactercreator/

WORKDIR /opt/tricll/charactercreator/

RUN yarn install
