# docker-dummy-certs

## What Does it Do?
It creates SSL certificates that are signed by either a custom CA, CA with an intermediate, or self-signed. A custom CA or intermediate certificate that already exists can also be used to sign the certificates.

## How to Use
To create certifcates:
````
docker run --rm -ti bradkwadsworth/dummy-certs
````
To use existing CA and intermediate certificates:
````
docker run --rm -ti \
  -v /path/to/ca/key:/etc/ssl/private/ca.key \
  -v /path/to/ca/cert:/etc/ssl/certs/ca.pem \
  -v /path/to/intermediate/key:/etc/ssl/private/intermediate.key \
  -v /path/to/intermediate/cert:/etc/ssl/certs/intermediate.pem \
  bradkwadsworth/dummy-certs
  ````
