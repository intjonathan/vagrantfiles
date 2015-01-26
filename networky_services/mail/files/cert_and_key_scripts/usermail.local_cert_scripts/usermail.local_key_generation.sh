#!/bin/bash

#Generate a 4096-bit RSA key called 'server.key':
openssl genrsa -out usermail.local.key 4096

#Generate a 4096-bit RSA key with AES256 encryption on the key itself (you'll be prompted for a password):
openssl genrsa -aes256 -out usermail.local.key 4096