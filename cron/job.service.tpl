[Unit]
Description=Daily backup 

[Service]
ExecStart=/usr/bin/rsync -aAXv /home/ /mnt/backup
