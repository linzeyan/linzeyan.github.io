#!/bin/bash

#'Generate CA key'
openssl genrsa -out ca.key 4096

#'Generate CA crt'
cacert.et

#'Generate server key'
openssl genrsa -out server.key 4096

#'Generate server csr'
servercsr.et

#'Sign server crt with CA crt and key'
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
