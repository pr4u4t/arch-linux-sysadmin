server.modules += ("mod_fastcgi")
index-file.names += ("index.php")

fastcgi.server = ( 
    # Load-balance requests for this path...
    ".php" => (
         "localhost" => ( 
            "bin-path" => "/usr/bin/php-cgi",
            "socket" => "/tmp/php-fastcgi.sock", 
            "broken-scriptfilename" => "enable", 
            "max-procs" => 4, # default value
            "bin-environment" => (
                "PHP_FCGI_CHILDREN" => "1" # default value
            )
        )
    )   
)
