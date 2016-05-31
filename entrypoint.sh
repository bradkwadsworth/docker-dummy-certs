#!/bin/sh
set -e

export CA_ROOT_KEY=${CA_ROOT_KEY:='/root/ca/private/ca.key.pem'}
export CA_ROOT_CERT=${CA_ROOT_CERT:='/root/ca/certs/ca.cert.pem'}
export CA_INTERMEDIATE_KEY=${CA_INTERMEDIATE_KEY:='/root/ca/intermediate/private/intermediate.key.pem'}
export CA_INTERMEDIATE_CERT=${CA_INTERMEDIATE_CERT:='/root/ca/intermediate/certs/intermediate.cert.pem'}

create_ca () {
  if [ ! -f "${CA_ROOT_KEY}" ]
  then
    echo
    echo "Generating CA root key."
    echo
    openssl genrsa -aes256 -out "${CA_ROOT_KEY}" 4096
    chmod 400 "${CA_ROOT_KEY}"
  fi

  if [ ! -f "${CA_ROOT_CERT}" ]
  then
    echo
    echo "Generating CA cert."
    echo
    openssl req -config /root/ca/openssl.cnf \
      -key "${CA_ROOT_KEY}" \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out "${CA_ROOT_CERT}"
    chmod 444 "${CA_ROOT_CERT}"
  fi
}

create_intermediate () {
  if [ ! -f "${CA_INTERMEDIATE_KEY}" ]
  then
    echo
    echo "Creating CA intermediate key."
    echo
    openssl genrsa -aes256 \
      -out "${CA_INTERMEDIATE_KEY}" 4096
    chmod 400 "${CA_INTERMEDIATE_KEY}"
  fi

  if [ ! -f "${CA_INTERMEDIATE_CERT}" ]
  then
    echo
    echo "Creating CA intermediate csr."
    echo
    openssl req -config /root/ca/openssl.cnf -new -sha256 \
      -key "${CA_INTERMEDIATE_KEY}" \
      -out /root/ca/intermediate/csr/intermediate.csr.pem

    echo
    echo "Signing CA intermediate certificate with root CA."
    echo
    openssl ca -config /root/ca/openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in /root/ca/intermediate/csr/intermediate.csr.pem \
      -out "${CA_INTERMEDIATE_CERT}"
    chmod 444 "${CA_INTERMEDIATE_CERT}"
  fi

}

echo
echo "Generate openssl.cnf file."
cat /tmp/openssl.cnf.template | DOLLAR='$' envsubst > /root/ca/openssl.cnf

echo
echo "Would you like to create a self-signed certificate(s), certificate signed by a CA(c), certificate signed by an intermediate certificate(i)?(s|c|i)?"
read TYPE

echo
echo "Creating server key."
echo
openssl genrsa -aes256 \
  -out /root/ca/private/key.pem 2048
chmod 400 /root/ca/private/key.pem

echo
echo "Creating certificate signing request."
echo
openssl req -config /root/ca/openssl.cnf \
  -key /root/ca/private/key.pem \
  -new -sha256 -out /root/ca/csr/csr.pem

case "${TYPE}" in
  s)
    echo
    echo "Creating self-signed certificate."
    echo
    openssl x509 -req -days 365 -in /root/ca/csr/csr.pem \
      -signkey /root/ca/private/key.pem -out /root/ca/certs/cert.pem
    ;;
  c)
    create_ca
    echo
    echo "Signing certificate signing request with CA certificate."
    echo
    openssl ca -config /root/ca/openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in /root/ca/csr/csr.pem \
      -out /root/ca/certs/cert.pem
    chmod 444 /root/ca/certs/cert.pem

    echo
    echo "Here is your CA Key."
    echo
    cat "${CA_ROOT_KEY}"

    echo
    echo "Here is your CA certificate."
    echo
    cat "${CA_ROOT_CERT}"
    ;;
  i)
    create_ca
    create_intermediate
    echo
    echo "Signing certificate signing request with intermediate certificate."
    echo
    openssl ca -config /root/ca/openssl.cnf -name CA_intermediate_dummy \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in /root/ca/csr/csr.pem \
      -out /root/ca/certs/cert.pem
   chmod 444 /root/ca/certs/cert.pem

   echo
   echo "Here is your CA Key."
   echo
   cat "${CA_ROOT_KEY}"

   echo
   echo "Here is your CA certificate."
   echo
   cat "${CA_ROOT_CERT}"

   echo
   echo "Here is your intermediate Key."
   echo
   cat "${CA_INTERMEDIATE_KEY}"

   echo
   echo "Here is your intermediate certificate."
   echo
   cat "${CA_INTERMEDIATE_CERT}"
   ;;
   *)
      echo
      echo "Must choose s, c or i"
      exit 1
     ;;
 esac

echo
echo "Here is your server key."
echo
cat /root/ca/private/key.pem

echo
echo "Here is your server certificate."
echo
cat /root/ca/certs/cert.pem
