FROM jess/httpie
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN apk add --no-cache socat iptables

COPY schmooze.sh /bin/schmooze.sh

ENTRYPOINT ["schmooze.sh"]
