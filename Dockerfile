FROM alpine
MAINTAINER Brad Wadsworth

ENV CA_ROOT_KEY='/root/ca/private/ca.key.pem' \
  CA_ROOT_CERT='/root/ca/certs/ca.cert.pem' \
  CA_INTERMEDIATE_KEY='/root/ca/intermediate/private/intermediate.key.pem' \
  CA_INTERMEDIATE_CERT='/root/ca/intermediate/certs/intermediate.cert.pem'


RUN apk update && \
  apk add openssl gettext && \
  rm /var/cache/apk/*

RUN mkdir /root/ca && \
  mkdir /root/ca/certs /root/ca/crl /root/ca/csr /root/ca/newcerts /root/ca/private && \
  chmod 700 /root/ca/private && \
  touch /root/ca/index.txt && \
  echo 1000 > /root/ca/serial  && \
  mkdir /root/ca/intermediate && \
  mkdir /root/ca/intermediate/certs /root/ca/intermediate/crl /root/ca/intermediate/csr /root/ca/intermediate/newcerts /root/ca/intermediate/private && \
  chmod 700 /root/ca/intermediate/private && \
  touch /root/ca/intermediate/index.txt && \
  echo 1000 > /root/ca/intermediate/serial && \
  echo 1000 > /root/ca/intermediate/crlnumber

ADD openssl.cnf.template /tmp/
ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
