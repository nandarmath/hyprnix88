{ config, pkgs, ...}:

{
 services.nginx = {
   enable = true;
   package = pkgs.nginx;

 # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

 # Only allow PFS-enabled ciphers with AES256
    # sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

# Setup Nextcloud virtual host to listen on ports
 virtualHosts = {
    "moodle" = {
       root = "/home/nandar/WebApp/moodle";
       extraConfig =''
        index index.php index.html;
       '';
     locations."~ \\.php$".extraConfig = ''
      fastcgi_pass  unix:${config.services.phpfpm.pools.mypool.socket};
      fastcgi_index index.php;
    '';
     locations."/".extraConfig = ''
              try_files $uri $uri/ /index.php?$args;
     '';
     locations."~* /(?:uploads|files)/.*\.php$".extraConfig = ''
              deny all; 
     '';
     locations."~* \.(js|css|png|jpg|jpeg|gif|ico)$".extraConfig = ''
                expires max;
                log_not_found off;
     '';
    };
    "umum" = {
       root = "/home/nandar/WebApp";
       listen = [{ port = 83;}];
       extraConfig = ''
        index index.php index.html;
        '';
    };
  };

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

  services.phpfpm.pools.mypool = {
    user = "nobody";
    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
  };
}

