# SSL Certificate Security

Use the following command to check a `*.crt` file for appropriate DNS entries:

```bash
openssl x509 -in {{FILENAME}} -noout -text | grep DNS:
```
