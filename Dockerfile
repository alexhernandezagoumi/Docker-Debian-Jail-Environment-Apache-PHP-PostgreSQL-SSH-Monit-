FROM scratch
  COPY debian_base/ / 
  COPY entrypoint.sh /home/entrypoint.sh
  RUN chmod +x /home/entrypoint.sh
  COPY web/testBDD.php /var/www/html/
  COPY web/index.php /var/www/html/
  ENV DEBIAN_FRONTEND=noninteractive
  RUN chroot / /bin/bash -c "\
    apt update && \
    apt install -y openssh-server && \
    apt install -y apache2 php libapache2-mod-php && \
    apt install -y php-pgsql postgresql postgresql-contrib && \
    systemctl enable apache2 \
  "
  RUN chroot / /bin/bash -c "\
    apt update && \
    apt install -y monit \
  "
  COPY monit/monitrc /etc/monit/monitrc
  RUN chmod 700 /etc/monit/monitrc
  EXPOSE 80 22 2812 
  ENTRYPOINT ["/home/entrypoint.sh"]
