CREATE OR REPLACE FUNCTION chownContent(newOwner VARCHAR(64))
RETURNS void AS
$$
	DECLARE
		tmp RECORD;
	BEGIN
		FOR tmp IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
			EXECUTE 'ALTER TABLE ' || quote_ident(tmp.tablename) || ' OWNER TO ' || quote_ident(newOwner);
		END LOOP;

		FOR tmp IN SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public' LOOP
			EXECUTE 'ALTER TABLE ' || quote_ident(tmp.sequence_name) || ' OWNER TO ' || quote_ident(newOwner);
		END LOOP;

		FOR tmp IN SELECT table_name FROM information_schema.views WHERE table_schema = 'public' LOOP
			EXECUTE 'ALTER TABLE ' || quote_ident(tmp.table_name) || ' OWNER TO ' || quote_ident(newOwner);
		END LOOP;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION addSipPeer(peerID VARCHAR(40),denyIP VARCHAR(95),secret VARCHAR(40),dtmfMode sip_dtmfmode_values,context VARCHAR(40),host VARCHAR(40),
					trustrpid yes_no_values,sendrpid yes_no_values,type type_values,nat VARCHAR(29),port INTEGER,qualify VARCHAR(40),qualifyfreq INTEGER,
					transport sip_transport_values,permit VARCHAR(95))
RETURNS boolean AS
$$
	BEGIN
		IF ( SELECT COUNT(*) FROM sippeers WHERE name = peerID ) <> 0 THEN
			RETURN false;
		END IF;

		INSERT INTO sippeers 	(name,  deny,	secret, dtmfmode, context, host, trustrpid, sendrpid, type, nat, port, qualify, qualifyfreq, transport, permit) 
			VALUES 		(peerID,denyIP, secret, dtmfMode, context, host, trustrpid, sendrpid, type, nat, port, qualify, qualifyfreq, transport, permit);
		
		RETURN true;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delSipPeer(peerID VARCHAR(40))
RETURNS boolean AS
$$
	BEGIN
		IF ( SELECT COUNT(*) FROM sippeers WHERE name = peerID ) <> 0 THEN
			RETURN false;
		END IF;

		DELETE FROM sippeers WHERE name = peerID;
		
		RETURN true;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION setSrtpEndpoint(endpointID VARCHAR(40),direct yesno_values,linePolicy pjsip_connected_line_method_values,
				directMethod pjsip_connected_line_method_values,natPolicy yesno_values,dtmfMode pjsip_dtmf_mode_values_v2,
				encMethod pjsip_media_encryption_values)
RETURNS boolean AS
$$
	BEGIN
		IF (SELECT COUNT(*) FROM ps_endpoints WHERE ps_endpoints.id = endpointID) = 0 THEN
			RETURN false;
		END IF;

		UPDATE ps_endpoints SET direct_media=direct,connected_line_method=linePolicy,direct_media_method=directMethod,
			disable_direct_media_on_nat=natPolicy,dtmf_mode=dtmfMode,media_encryption=encMethod WHERE ps_endpoints.id = endpointID;

		RETURN true;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clearSrtpEndpoint(endpointID VARCHAR(40))
RETURNS boolean AS
$$
	BEGIN
		IF (SELECT COUNT(*) FROM ps_endpoints WHERE ps_endpoints.id = endpointID) = 0 THEN
			RETURN false;
		END IF;

		UPDATE ps_endpoints SET media_encryption='no' WHERE ps_endpoints.id = endpointID;

		RETURN true;

	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION addEndpoint(owner VARCHAR(255),endpointID VARCHAR(40),secret VARCHAR(80),auth pjsip_auth_type_values,
				transport VARCHAR(40),context VARCHAR(40),disallow VARCHAR(40) = '',allow VARCHAR(80) = 'gsm',
				direct yesno_values = 'yes',len INTEGER = 4)
RETURNS boolean AS
$$
	BEGIN
		IF endpointID NOT SIMILAR TO '[0-9]{' || CAST( len as varchar) || ',}' THEN
			RETURN false;
		END IF;
		
		IF (SELECT COUNT(*) FROM ps_aors WHERE ps_aors.id = endpointID) > 0 THEN
			RETURN false;
		END IF;

		IF (SELECT COUNT(*) FROM ps_auths WHERE ps_auths.id = endpointID) > 0 THEN
			RETURN false;
		END IF;

		IF (SELECT COUNT(*) FROM ps_endpoints WHERE ps_endpoints.id = endpointID) > 0 THEN
			RETURN false;
		END IF;

		INSERT INTO ps_aors (id,max_contacts) VALUES (endpointID,1);
		INSERT INTO ps_auths (id,auth_type,password,username) VALUES (endpointID,auth,secret,endpointID);
		INSERT INTO ps_endpoints (id,transport,aors,auth,context,disallow,allow,direct_media) 
			VALUES (endpointID,transport,endpointID,endpointID,context,disallow,allow,direct);

		RETURN true;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION setEndpointTransport(endpointID VARCHAR(40),trans VARCHAR(40))
RETURNS boolean AS
$$
	BEGIN
		IF (SELECT COUNT(*) FROM ps_endpoints WHERE ps_endpoints.id = endpointID) = 0 THEN
                        RETURN false;
                END IF;

		UPDATE ps_endpoints SET transport=trans WHERE ps_endpoints.id = endpointID;

		RETURN true;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delEndpoint(endpointID VARCHAR(40),len INTEGER = 4)
RETURNS boolean AS
$$
	BEGIN
		/*IF endpointID NOT SIMILAR TO '[0-9]{' || CAST( len as varchar) || ',}' THEN
			RETURN false;
		END IF;*/
		
		IF (SELECT COUNT(*) FROM ps_aors WHERE ps_aors.id = endpointID) > 0 THEN
			DELETE FROM ps_aors WHERE ps_aors.id = endpointID;
		END IF;

		IF (SELECT COUNT(*) FROM ps_auths WHERE ps_auths.id = endpointID) > 0 THEN
			DELETE FROM ps_auths WHERE ps_auths.id = endpointID;
		END IF;

		IF (SELECT COUNT(*) FROM ps_endpoints WHERE ps_endpoints.id = endpointID) > 0 THEN
			DELETE FROM ps_endpoints WHERE ps_endpoints.id = endpointID;
		END IF;

		RETURN true;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION endpointPassword(endpointID VARCHAR(40))
RETURNS VARCHAR(80) AS
$$
	DECLARE 
		ret VARCHAR(80);
	BEGIN
		SELECT password INTO ret FROM ps_auths WHERE ps_auths.id = endpointID;
		RETURN ret;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION setEndpointPassword(endpointID VARCHAR(40),newPassword VARCHAR(80))
RETURNS boolean AS
$$
	BEGIN
		IF (SELECT COUNT(*) FROM ps_auths WHERE ps_auths.id = endpointID) = 0 THEN
                        RETURN false;
                END IF;

                UPDATE ps_endpoints SET password=newPassword WHERE ps_auths.id = endpointID;

                RETURN true;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION endpoints()
RETURNS SETOF VARCHAR(40) AS
$$
	BEGIN
		return QUERY SELECT ps_endpoints.id FROM ps_endpoints;
	END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION setEndpointOptions()
RETURNS boolean AS
$$
	BEGIN
		RETURN true;
	END
$$
LANGUAGE plpgsql;

/*
srtpEndpoint(endpointID VARCHAR(40),direct yesno_values,linePolicy pjsip_connected_line_method_values,
                                directMethod pjsip_connected_line_method_values,natPolicy yesno_values,dtmfMode pjsip_dtmf_mode_values_v2,
                                encMethod pjsip_media_encryption_values)
*/

/*GRANT ALL ON DATABASE asterisk TO asterisk;*/
/*SELECT chownContent('asterisk');*/
/*SELECT addEndpoint('owner','0004','1234','userpass','transport-udp','internal','all','gsm','yes',4);*/
/*SELECT srtpEndpoint('0004','yes','reinvite','reinvite','no','info','sdes');*/
