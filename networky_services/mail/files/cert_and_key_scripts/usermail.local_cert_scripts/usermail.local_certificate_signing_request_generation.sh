#!/bin/bash

#Generate a 4096-bit RSA key and matching CSR with one command:
openssl req -out usermail.local.csr -new -newkey rsa:4096 -nodes -keyout usermail.local.key

