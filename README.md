# dummy-certs

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
  -v /path/to/certs/dir:/certs \
  bradkwadsworth/dummy-certs
````
To pass Subject Alternative Names set the SAN environment variable
````
docker run --rm -ti \
  -e SAN='DNS:somehost,DNS:anotherhost,IP:1.2.3.4' \
  bradkwadsworth/dummy-certs
````
