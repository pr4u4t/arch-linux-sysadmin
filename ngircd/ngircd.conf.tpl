[Global]
	Name = ${NAME}
	;AdminInfo1 = Description
	;AdminInfo2 = Location
	;AdminEMail = admin@irc.server

	# Text file which contains the ngIRCd help text. This file is required
	# to display help texts when using the "HELP <cmd>" command.
	;HelpFile = /usr/share/doc/ngircd/Commands.txt

	# Info text of the server. This will be shown by WHOIS and
	# LINKS requests for example.
	Info = ${INFO}

	# Comma separated list of IP addresses on which the server should
	# listen. Default values are:
	# "0.0.0.0" or (if compiled with IPv6 support) "::,0.0.0.0"
	# so the server listens on all IP addresses of the system by default.
	Listen = "${LISTEN}"

	# Text file with the "message of the day" (MOTD). This message will
	# be shown to all users connecting to the server:
	;MotdFile = /etc/ngircd.motd

	# A simple Phrase (<256 chars) if you don't want to use a motd file.
	;MotdPhrase = "Hello world!"

	# The name of the IRC network to which this server belongs. This name
	# is optional, should only contain ASCII characters, and can't contain
	# spaces. It is only used to inform clients. The default is empty,
	# so no network name is announced to clients.
	;Network = aIRCnetwork

	# Global password for all users needed to connect to the server.
	# (Default: not set)
	;Password = ${PASSWORD}

	# This tells ngIRCd to write its current process ID to a file.
	# Note that the pidfile is written AFTER chroot and switching the
	# user ID, e.g. the directory the pidfile resides in must be
	# writable by the ngIRCd user and exist in the chroot directory.
	;PidFile = /var/run/ngircd/ngircd.pid

	# Ports on which the server should listen. There may be more than
	# one port, separated with ",". (Default: 6667)
	Ports = 
	#6601, 6667, 6668, 6669

	# Group ID under which the ngIRCd should run; you can use the name
	# of the group or the numerical ID. ATTENTION: For this to work the
	# server must have been started with root privileges!
	ServerGID = ${SERVER_GID}

	# User ID under which the server should run; you can use the name
	# of the user or the numerical ID. ATTENTION: For this to work the
	# server must have been started with root privileges! In addition,
	# the configuration and MOTD files must be readable by this user,
	# otherwise RESTART and REHASH won't work!
	ServerUID = ${SERVER_UID}

[Limits]
	# Define some limits and timeouts for this ngIRCd instance. Default
	# values should be safe, but it is wise to double-check :-)

	# The server tries every <ConnectRetry> seconds to establish a link
	# to not yet (or no longer) connected servers.
	;ConnectRetry = 60

	# Number of seconds after which the whole daemon should shutdown when
	# no connections are left active after handling at least one client
	# (0: never, which is the default).
	# This can be useful for testing or when ngIRCd is started using
	# "socket activation" with systemd(8), for example.
	;IdleTimeout = 0

	# Maximum number of simultaneous in- and outbound connections the
	# server is allowed to accept (0: unlimited):
	;MaxConnections = 0

	# Maximum number of simultaneous connections from a single IP address
	# the server will accept (0: unlimited):
	;MaxConnectionsIP = 5

	# Maximum number of channels a user can be member of (0: no limit):
	;MaxJoins = 10

	# Maximum length of an user nickname (Default: 9, as in RFC 2812).
	# Please note that all servers in an IRC network MUST use the same
	# maximum nickname length!
	;MaxNickLength = 9

	# Maximum number of channels returned in response to a /list
	# command (0: unlimited):
	;MaxListSize = 100

	# After <PingTimeout> seconds of inactivity the server will send a
	# PING to the peer to test whether it is alive or not.
	;PingTimeout = 120

	# If a client fails to answer a PING with a PONG within <PongTimeout>
	# seconds, it will be disconnected by the server.
	;PongTimeout = 20

[Options]
	# Optional features and configuration options to further tweak the
	# behavior of ngIRCd. If you want to get started quickly, you most
	# probably don't have to make changes here -- they are all optional.

	# List of allowed channel types (channel prefixes) for newly created
	# channels on the local server. By default, all supported channel
	# types are allowed. Set this variable to the empty string to disallow
	# creation of new channels by local clients at all.
	;AllowedChannelTypes = #&+

	# Are remote IRC operators allowed to control this server, e.g.
	# use commands like CONNECT, SQUIT, DIE, ...?
	;AllowRemoteOper = no

	# A directory to chroot in when everything is initialized. It
	# doesn't need to be populated if ngIRCd is compiled as a static
	# binary. By default ngIRCd won't use the chroot() feature.
	# ATTENTION: For this to work the server must have been started
	# with root privileges!
	;ChrootDir = /var/empty

	# Set this hostname for every client instead of the real one.
	# Use %x to add the hashed value of the original hostname.
	CloakHost = ${CLOAK_HOST}

	# Use this hostname for hostname cloaking on clients that have the
	# user mode "+x" set, instead of the name of the server.
	# Use %x to add the hashed value of the original hostname.
	;CloakHostModeX = cloaked.user

	# The Salt for cloaked hostname hashing. When undefined a random
	# hash is generated after each server start.
	;CloakHostSalt = abcdefghijklmnopqrstuvwxyz

	# Set every clients' user name to their nickname
	;CloakUserToNick = yes

	# Try to connect to other IRC servers using IPv4 and IPv6, if possible.
	;ConnectIPv6 = yes
	;ConnectIPv4 = yes

	# Default user mode(s) to set on new local clients. Please note that
	# only modes can be set that the client could set using regular MODE
	# commands, you can't set "a" (away) for example! Default: none.
	;DefaultUserModes = i

	# Do DNS lookups when a client connects to the server.
	DNS = no

	# Do IDENT lookups if ngIRCd has been compiled with support for it.
	# Users identified using IDENT are registered without the "~" character
	# prepended to their user name.
	;Ident = yes

	# Directory containing configuration snippets (*.conf), that should
	# be read in after parsing this configuration file.
	IncludeDir = ${INCLUDE_DIR}

	# Enhance user privacy slightly (useful for IRC server on TOR or I2P)
	# by censoring some information like idle time, logon time, etc.
	MorePrivacy = yes

	# Normally ngIRCd doesn't send any messages to a client until it is
	# registered. Enable this option to let the daemon send "NOTICE AUTH"
	# messages to clients while connecting.
	;NoticeAuth = no

	# Should IRC Operators be allowed to use the MODE command even if
	# they are not(!) channel-operators?
	;OperCanUseMode = no

	# Should IRC Operators get AutoOp (+o) in persistent (+P) channels?
	;OperChanPAutoOp = yes

	# Mask IRC Operator mode requests as if they were coming from the
	# server? (This is a compatibility hack for ircd-irc2 servers)
	;OperServerMode = no

	# Use PAM if ngIRCd has been compiled with support for it.
	# Users identified using PAM are registered without the "~" character
	# prepended to their user name.
	PAM = yes

	# When PAM is enabled, all clients are required to be authenticated
	# using PAM; connecting to the server without successful PAM
	# authentication isn't possible.
	# If this option is set, clients not sending a password are still
	# allowed to connect: they won't become "identified" and keep the "~"
	# character prepended to their supplied user name.
	# Please note: To make some use of this behavior, it most probably
	# isn't useful to enable "Ident", "PAM" and "PAMIsOptional" at the
	# same time, because you wouldn't be able to distinguish between
	# Ident'ified and PAM-authenticated users: both don't have a "~"
	# character prepended to their respective user names!
	PAMIsOptional = no

	# Let ngIRCd send an "authentication PING" when a new client connects,
	# and register this client only after receiving the corresponding
	# "PONG" reply.
	;RequireAuthPing = no

	# Silently drop all incoming CTCP requests.
	;ScrubCTCP = no

	# Syslog "facility" to which ngIRCd should send log messages.
	# Possible values are system dependent, but most probably auth, daemon,
	# user and local1 through local7 are possible values; see syslog(3).
	# Default is "local5" for historical reasons, you probably want to
	# change this to "daemon", for example.
	;SyslogFacility = local1

	# Password required for using the WEBIRC command used by some
	# Web-to-IRC gateways. If not set/empty, the WEBIRC command can't
	# be used. (Default: not set)
	;WebircPassword = xyz

[Operator]
	# [Operator] sections are used to define IRC Operators. There may be
	# more than one [Operator] block, one for each local operator.

	# ID of the operator (may be different of the nickname)
	;Name = TheOper

	# Password of the IRC operator
	;Password = ThePwd

	# Optional Mask from which /OPER will be accepted
	;Mask = *!ident@somewhere.example.com

[Channel]
	# Pre-defined channels can be configured in [Channel] sections.
	# Such channels are created by the server when starting up and even
	# persist when there are no more members left.
	# Persistent channels are marked with the mode 'P', which can be set
	# and unset by IRC operators like other modes on the fly.
	# There may be more than one [Channel] block, one for each channel.

	# Name of the channel
	;Name = #TheName

	# Topic for this channel
	;Topic = a great topic

	# Initial channel modes
	;Modes = tnk

	# initial channel password (mode k)
	;Key = Secret

	# Key file, syntax for each line: "<user>:<nick>:<key>".
	# Default: none.
	;KeyFile = /etc/#chan.key

	# maximum users per channel (mode l)
	;MaxUsers = 23
# -eof-
