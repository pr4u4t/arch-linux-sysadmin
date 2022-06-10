[SSL]
        # SSL-related configuration options. Please note that this section
        # is only available when ngIRCd is compiled with support for SSL!
        # So don't forget to remove the ";" above if this is the case ...

        # SSL Server Key Certificate
        CertFile = ${CERT_FILE}

        # Select cipher suites allowed for SSL/TLS connections. This defaults
        # to HIGH:!aNULL:@STRENGTH (OpenSSL) or SECURE128 (GnuTLS).
        # See 'man 1ssl ciphers' (OpenSSL) or 'man 3 gnutls_priority_init'
        # (GnuTLS) for details.
        # For OpenSSL:
        CipherList = HIGH:!aNULL:@STRENGTH:!SSLv3
        # For GnuTLS:
        ;CipherList = SECURE128:-VERS-SSL3.0

        # Diffie-Hellman parameters
        DHFile = ${DH_FILE}

        # SSL Server Key
        KeyFile = ${KEY_FILE}

        # password to decrypt SSLKeyFile (OpenSSL only)
        ;KeyFilePassword = secret

        # Additional Listen Ports that expect SSL/TLS encrypted connections
        Ports = ${PORT}
