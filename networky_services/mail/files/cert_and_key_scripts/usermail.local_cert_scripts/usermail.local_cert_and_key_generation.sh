#!/bin/bash

#Create a 4096-bit RSA key and matching certificate without the intermediate step of creating a CSR:
openssl req -x509 -batch -nodes -newkey rsa:4096 -keyout usermail.local.key -out usermail.local.pem -config usermail.local_openssl.conf