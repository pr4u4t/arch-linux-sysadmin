[Unit]
Description=Daily backup 

[Timer]
OnCalendar=daily
Persistent=true     
 
[Install]
WantedBy=timers.target
