server ${LOCAL_SERVER} iburst
#server 1.pool.ntp.org iburst
#server 2.pool.ntp.org iburst
#server 3.pool.ntp.org iburst

restrict ${DEFAULT_RESTRICT_OPTIONS}
restrict ${DEFAULT_RESTRICT_IP}

driftfile ${DRIFT_FILE}
logfile ${LOG_FILE}
