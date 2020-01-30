FROM smellman/postgis:12-master-alpine

RUN set -ex \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    \
    && wget -O mapnik-german-l10n.tar.gz "https://github.com/giggls/mapnik-german-l10n/archive/v2.5.8.tar.gz" \
    && mkdir -p /usr/src/mapnik-german-l10n \
    && tar \
        --extract \
        --file mapnik-german-l10n.tar.gz \
        --directory /usr/src/mapnik-german-l10n \
        --strip-components 1 \
    && rm mapnik-german-l10n.tar.gz \
    && wget -O kakasi.tar.gz "http://kakasi.namazu.org/stable/kakasi-2.3.6.tar.gz" \
    && mkdir -p /usr/src/kakasi \
    && tar \
        --extract \
        --file kakasi.tar.gz \
        --directory /usr/src/kakasi \
        --strip-components 1 \
    && rm kakasi.tar.gz \
    \
    && apk add --no-cache --virtual .build-deps \
        curl \
        sed \
        make \
        gcc \
        g++ \
        icu-dev \
        libc-dev \
        utf8proc-dev \
    && cd /usr/src/kakasi \
    && ./configure \
    && make \
    && make install \
    && cd /usr/src/mapnik-german-l10n \
    && touch INSTALL.html && touch INSTALL \
    && touch README.html && touch README \
    && touch TODO.html && touch TODO \
    && sed -i "s/| cat -s//g" gen_osml10n_extension.sh \
    && make \
    && make install \
    && apk add --no-cache --virtual .mapnik-german-l10n-rundeps \
        utf8proc \
        icu \
    && cd / \
    && rm -fr /usr/src/kakasi \
    && rm -rf /usr/src/mapnik-german-l10n \
    && apk del .fetch-deps .build-deps
    
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh

