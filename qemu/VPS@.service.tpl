[Unit]
Description=QEMU VPS %i
After=network.target

[Service]
Type=forking
PIDFile=/run/qemu/%i.pid
ExecStart=/home/vps/bin/vps_start %i
ExecStop=/home/vps/bin/vps_stop %i

[Install]
WantedBy=multi-user.target
