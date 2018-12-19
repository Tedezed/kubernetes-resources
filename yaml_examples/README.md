# Examples 

## Command over multiple lines

Example for add support of tls to Prestashop official image:
```
spec:
  containers:
  - command:
    - /bin/bash
    - -c
    - |
      apt-get update; apt-get install recode -y; echo 'set -x 
      && a2enmod ssl
      && echo "
      127.0.0.1  ps.example.es
      " >> /etc/hosts
      && openssl req -x509 -nodes -days 360 -subj "/CN=ps.example.es" -newkey rsa:1024 -keyout /tmp/server.key -out /tmp/server.crt
      && chown www-data:www-data /tmp/server.key /tmp/server.crt
      && echo "
      <VirtualHost *:443>
        DocumentRoot /var/www/html
        SSLEngine on
        SSLCertificateFile /tmp/server.crt
        SSLCertificateKeyFile /tmp/server.key
      </VirtualHost>
      " >> /etc/apache2/sites-enabled/000-default.conf
      && sh /tmp/docker_run.sh' | recode html..ascii > /tmp/custom_init.bash; bash /tmp/custom_init.bash
  image: prestashop/prestashop:1.6
  name: ps-test
  ports:
  - containerPort: 80
    name: http
    protocol: TCP
  - containerPort: 443
    name: https
    protocol: TCP
```
