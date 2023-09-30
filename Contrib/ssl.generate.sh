############

openssl genrsa -des3 -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt
openssl genrsa -des3 -out server.key 4096
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
echo "01" >ca.srl
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -out server.crt
openssl rsa -noout -text -in server.key
openssl req -noout -text -in server.csr
openssl rsa -noout -text -in ca.key
openssl x509 -noout -text -in ca.crt
openssl rsa -in server.key -out server.key.insecure
mv server.key server.key.secure
mv server.key.insecure server.key

# cp server.key /etc/httpd/ssl.key
# cp server.crt /etc/httpd/ssl.crt
# cp server.csr /etc/httpd/ssl.csr