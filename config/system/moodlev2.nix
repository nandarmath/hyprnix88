{config, pkgs, ...}:
{

  # Nginx 
  services.nginx = {
    enable = true;
    package = pkgs.nginxStable;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    #virtualHosts."localhost".listen = [ { addr = "127.0.0.1"; port = 80; } ];
    config = ''
      
      worker_processes auto;
      worker_rlimit_nofile 65535;
      pid /run/nginx.pid;

      events {
	      worker_connections 10240;
	      use epoll;
	      multi_accept on;
      }

      http {

	        ### Basic Settings ##

	       client_max_body_size 100m;
	       client_body_buffer_size 128k;
	       client_header_buffer_size 1k;
	       large_client_header_buffers 4 4k;

	       client_body_timeout 12;
	       client_header_timeout 12;
	       send_timeout 60;
	       keepalive_timeout 15;
	       keepalive_requests 500;
	       reset_timedout_connection on;

	       sendfile on;
	       tcp_nopush on;
	       tcp_nodelay on;

	       fastcgi_buffers 16 16k;
	       fastcgi_buffer_size 32k;
	       fastcgi_connect_timeout 300s;
	       fastcgi_send_timeout 300s;
	       fastcgi_read_timeout 300s;

	       open_file_cache max=20000 inactive=20s;
	       open_file_cache_valid 45s;
	       open_file_cache_min_uses 3;
	       open_file_cache_errors on;

	       types_hash_max_size 2048;
	       server_tokens off;

	       include /etc/nginx/mime.types;
	       default_type application/octet-stream;

        ### Gzip Settings ##

	       gzip on;

	       gzip_vary on;
	       gzip_proxied any;
	       gzip_comp_level 6;
	       gzip_buffers 16 8k;
	       gzip_http_version 1.1;
	       gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
      }


    '';
  };
  
  # Php option (php.ini)
  services.phpfpm.phpOptions = ''
    date.timezone = "Asia/Jakarta";
    display_errors = on;
    upload_max_filesize = "100M";
    post_max_size = "100M";
  '';

  # Moodle
  services.moodle ={
    enable = true;
    package = pkgs.moodle;
    database.user = "moodle";
    database.type = "pgsql";
    database.port = 5432;
    database.name = "moodle";
    database.createLocally = true;
    database.host = "localhost";
    #database.passwordFile = "/home/nandar/zaneyos/config/home/files/dbmoodle-pass";
    initialPassword = "@nandar88";
    virtualHost = {
      #hostName = "127.0.0.1";
      adminAddr = "nandarmath@gmail.com";
      forceSSL = false;
      enableACME = false;
    };
    
    virtualHost.listen = [{ port = 80;}];
    virtualHost.listenAddresses = ["*"];
    extraConfig = ''
      $protocol='http://';
      $hostname='127.0.0.1';
      if (isset($_SERVER['HTTPS'])) { $protocol='https://'; }
      if (isset($_SERVER['HTTP_HOST'])) { $hostname=$_SERVER['HTTP_HOST']; }
      $CFG->wwwroot = $protocol.$hostname;
    '';

    
  };

  # Database
  # Enable PostgreSQL 
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;

    # Ensure the database, user, and permissions always exist
 #  ensureDatabases = [ "moodledb" ];
 #  ensureUsers = [
 #   { name = "moodleuser";
 #     #ensurePermissions."DATABASE moodledb" = "ALL PRIVILEGES";
 #   }
 #  ];
 #  initialScript = pkgs.writeText "backend-initScript" ''
 #    CREATE ROLE moodleuser WITH LOGIN PASSWORD 'moodle24' CREATEDB;
 #    CREATE DATABASE moodledb;
 #    GRANT ALL PRIVILEGES ON DATABASE moodledb TO moodleuser;
 #  '';

  };

  #  Ensure 
# Ensure that postgres is running before running the setup
  systemd.services."moodle-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
















}
