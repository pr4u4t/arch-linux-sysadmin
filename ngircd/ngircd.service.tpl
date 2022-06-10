[Unit]
Description=Next Generation IRC Daemon
After=network.target

[Service]
# don't daemonize to simplify stuff
ExecStart=/usr/bin/ngircd -n -f ${CONF_PATH}
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
