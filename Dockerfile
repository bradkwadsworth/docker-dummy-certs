FROM alpine
MAINTAINER Brad Wadsworth

RUN apk update && \
  apk add openssl && \
  rm /var/cache/apk/*

RUN mkdir /etc/ssl/crl /etc/ssl/csr /etc/ssl/newcerts /etc/ssl/CA /etc/ssl/intermediate &&\
  touch /etc/ssl/CA/index.txt &&\
  echo 1000 > /etc/ssl/CA/serial  &&\
  touch /etc/ssl/intermediate/index.txt &&\
  echo 1000 > /etc/ssl/intermediate/serial &&\
  echo 1000 > /etc/ssl/intermediate/crlnumber

ADD openssl.cnf /etc/ssl/
ADD create-certs.sh /
RUN chmod +x /create-certs.sh


ENTRYPOINT ["/create-certs.sh"]
