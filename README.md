## **HTTPs Web Server**

```
$ mkdir -p certs/
$ cd certs/
$ openssl req -newkey rsa:2048 -nodes -sha256 -x509 -days 365 \
-out cert.crt \
-keyout cert.key \
-subj "/CN=localhost"

$ cd ../
$ make
```
