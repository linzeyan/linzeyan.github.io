FROM golang:1.12.1-stretch
RUN go get github.com/jxskiss/ssl-cert-server
CMD ["/go/bin/ssl-cert-server", "--listen=0.0.0.0:8999", "--email=sslcertserver@gmail.com", "--cache-dir=/certs"]
