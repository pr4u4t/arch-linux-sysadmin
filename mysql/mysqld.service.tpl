[Unit]
Description=MariaDB database server
After=syslog.target

[Service]
User=${USER}
Group=${GROUP}

ExecStart=/usr/bin/mysqld --defaults-file=${HOME_DIR}/${NAME}/my.cnf --pid-file=/run/mysqld/mysqld-${NAME}.pid --wsrep-data-home-dir=${HOME_DIR}/${NAME} --datadir=${HOME_DIR}/${NAME}

#ExecStartPost=/usr/bin/mysqld-post

Restart=always
PrivateTmp=true

[Install]
WantedBy=multi-user.target
