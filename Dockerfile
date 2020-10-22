FROM alpine:3.12.1

ARG LUFI_VERSION=master

ENV GID=991 \
    UID=991 \
    LUFI_DIR=/usr/lufi

LABEL description="lufi on alpine" \
      maintainer="victor-rds <https://github.com/victor-rds>"

RUN apk add --update --no-cache --virtual .build-deps \
                build-base \
                libressl-dev \
                ca-certificates \
                git \
                tar \
                perl-dev \
                libidn-dev \
                postgresql-dev \
                mariadb-dev \
                wget \
    && apk add --update --no-cache \
                libressl \
                perl \
                libidn \
                perl-crypt-rijndael \
                perl-test-manifest \
                perl-net-ssleay \
                tini \
                su-exec \
                postgresql-libs \
    && echo | cpan \
    && cpan install CPAN \
    && cpan reload CPAN \
    && cpan install Carton \
    && git clone -b ${LUFI_VERSION} https://framagit.org/luc/lufi.git ${LUFI_DIR} \
    && cd ${LUFI_DIR} \
    #&& rm cpanfile.snapshot \
    && carton install --deployment --without=test --without=swift-storage --without=ldap \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /root/.cpan* ${LUFI_DIR}/local/cache/*

WORKDIR ${LUFI_DIR}
VOLUME ${LUFI_DIR}/data ${LUFI_DIR}/files
EXPOSE 8081

COPY startup /usr/local/bin/startup
COPY lufi.conf.template ${LUFI_DIR}/lufi.conf.template
RUN chmod +x /usr/local/bin/startup

CMD ["/usr/local/bin/startup"]
