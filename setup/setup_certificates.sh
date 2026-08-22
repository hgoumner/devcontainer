#!/bin/bash

mkdir -p certificates
cd certificates || exit

security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".crt"; print >out}'
security find-certificate -a -p /Library/Keychains/System.keychain | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".crt"; print >out}'

for cert in *.crt; do
    newname=$(openssl x509 -noout -subject -in "$cert" | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]').crt
    mv -f "${cert}" "${newname}"
    echo "${newname}"
done

cd - || exit

podman cp ./certificates/. "$CONTAINER_NAME":/usr/local/share/ca-certificates/
podman exec "$CONTAINER_NAME" sudo update-ca-certificates

