FROM outstand/ruby-base:2.5.0-alpine
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN apk --no-cache add build-base iptables

WORKDIR /srv
COPY Gemfile Gemfile.lock /srv/
COPY lib/schmooze/version.rb /srv/lib/schmooze/
COPY docker/fetch-cache.sh /srv/docker/

ARG cache_host
RUN docker/fetch-cache.sh ${cache_host} && \
  bundle install
COPY . /srv/
RUN ln -s /srv/exe/schmooze /usr/local/bin/schmooze

COPY docker/irbrc /home/schmooze/.irbrc
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["help"]
