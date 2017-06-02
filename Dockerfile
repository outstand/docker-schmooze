FROM outstand/ruby-base:2.4.1-alpine
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN addgroup -S schmooze && \
    adduser -S -G schmooze schmooze && \
    addgroup -g 1101 docker && \
    addgroup schmooze docker

RUN apk --no-cache add build-base

WORKDIR /srv
COPY Gemfile Gemfile.lock /srv/
COPY lib/schmooze/version.rb /srv/lib/schmooze/
COPY docker/fetch-cache.sh /srv/docker/

ARG cache_host
RUN docker/fetch-cache.sh ${cache_host} && \
  gosu schmooze bundle install
COPY . /srv/
RUN chown -R schmooze:schmooze /srv
RUN ln -s /srv/exe/schmooze /usr/local/bin/schmooze

COPY docker/irbrc /home/schmooze/.irbrc
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["help"]
