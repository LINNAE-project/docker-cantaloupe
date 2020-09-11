FROM debian:buster

ENV CANTALOUPE_VERSION=4.1.6

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy \
    && apt-get dist-upgrade -qy\
    && apt-get install -qy --no-install-recommends \
        curl \
        imagemagick \
        libopenjp2-tools \
        ffmpeg \
        unzip \
        default-jre-headless \
    && apt-get -qqy autoremove \
    && apt-get -qqy autoclean

# Run non-privileged
RUN adduser --system cantaloupe

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/cantaloupe-project/cantaloupe/releases/download/v${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.zip \
    && unzip cantaloupe-${CANTALOUPE_VERSION}.zip \
    && rm -f cantaloupe-${CANTALOUPE_VERSION}.zip \
    && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
    && mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
    && chown -R cantaloupe cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    && cp -rs /cantaloupe/deps/Linux-x86-64/* /usr/

# Copy customized config files
COPY cantaloupe.properties delegates.rb /cantaloupe/

USER cantaloupe

CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties -jar /cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]
