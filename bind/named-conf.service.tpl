[Unit]
Description=Internet domain name server
After=network.target

[Service]
ExecStart=/usr/bin/named -f -u named -c ${BIND_DIR}/named.conf
ExecReload=/usr/bin/rndc reload
ExecStop=/usr/bin/rndc stop

[Install]
WantedBy=multi-user.target
