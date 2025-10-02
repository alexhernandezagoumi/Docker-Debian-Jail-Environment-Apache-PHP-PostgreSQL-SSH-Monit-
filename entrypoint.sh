#!/bin/bash
  USER_NAME="${USER_NAME:-usuario}"
  USER_PASS="${USER_PASS:-usuaria}"
  PUBLIC_KEY=${PUBLIC_KEY}
  DB_USER="${DB_USER:-dbadmin}"
  DB_PASS="${DB_PASS:-*1234Root}"
  DB_NAME="${DB_NAME:-postgresdb}"
  chroot / /bin/bash -c "\
    id $USER_NAME >/dev/null 2>&1 || ( \
        useradd -m -s /bin/bash $USER_NAME && \
        echo '$USER_NAME:$USER_PASS' | chpasswd && \
        usermod -aG sudo $USER_NAME \
    )"
  mkdir -p /home/$USER_NAME/.ssh
  echo $PUBLIC_KEY > /home/$USER_NAME/.ssh/authorized_keys
  chmod 700 /home/$USER_NAME/.ssh
  chmod 600 /home/$USER_NAME/.ssh/authorized_keys
  chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
  service postgresql stop
  mkdir -p /var/run/postgresql
  chown postgres:postgres /var/run/postgresql
  chmod 775 /var/run/postgresql
  if [ ! -f /var/lib/postgresql/15/main/postgresql.conf ]; then
    echo "Inicializando PostgreSQL..." &&
    rm -rf /var/lib/postgresql/15/main/* &&
    su - postgres -c "/usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/15/main";
  fi
  su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D /var/lib/postgresql/15/main -l /var/log/postgresql/postgres.log start"
  su - postgres -c "psql -c \"CREATE USER \\\"$DB_USER\\\" WITH PASSWORD '$DB_PASS';\""
  su - postgres -c "psql -c \"ALTER USER \\\"$DB_USER\\\" CREATEDB;\""
  su - postgres -c "psql -c \"CREATE DATABASE \\\"$DB_NAME\\\" WITH OWNER \\\"$DB_USER\\\";\""
  su - postgres -c "psql -d \"bddprueba1\" -c \"CREATE EXTENSION IF NOT EXISTS pgcrypto;\""
  su - postgres -c "psql -d \"$DB_NAME\" -c \"CREATE TABLE IF NOT EXISTS credenciales (id SERIAL PRIMARY KEY, nombre_usuario TEXT NOT NULL UNIQUE, contrasena TEXT NOT NULL);\""
  su - postgres -c "psql -d \"$DB_NAME\" -c \"GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \\\"$DB_USER\\\";\""
  su - postgres -c "psql -d \"$DB_NAME\" -c \"INSERT INTO credenciales (nombre_usuario, contrasena) VALUES ('$DB_USER', crypt('$DB_PASS', gen_salt('bf')));\""
  sed -i '/^\$dbname/d' /var/www/html/testBDD.php
  sed -i '/^\$user/d' /var/www/html/testBDD.php
  sed -i '/^\$password/d' /var/www/html/testBDD.php
  sed -i "/^\$port *=/a \$dbname = \"${DB_NAME}\";\n\$user = \"${DB_USER}\";\n\$password = \"${DB_PASS}\";" /var/www/html/testBDD.php
  sed -i -E 's/(dbname=)[^ ]+/\1'"$DB_NAME"'/; s/(user=)[^ ]+/\1'"$DB_USER"'/; s/(password=)[^ )"]+/\1'"$DB_PASS"'/' /var/www/html/index.php
  rm /var/www/html/index.html
  mkdir -p /var/run/sshd
  chroot / /usr/sbin/sshd
  chroot / /bin/bash -c "monit -c /etc/monit/monitrc"
  exec chroot / /usr/sbin/apache2ctl -D FOREGROUND
  chmod 700 /etc/monit/monitrc
  monit reload
  monit start all
