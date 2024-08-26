{ lib, config, pkgs, ... }:

{

 services.nginx = {
  package=pkgs.nginxStable;
  user = "nginx";
  group = "users";
  enable = true;
  config =''
    server {
    listen 80;
    server_name default_server;
    root /home/nandar/WebApp;
    index index.php index.html index.htm;
 
    location / {
    	try_files $uri $uri/ /index.php?$query_string;       
    }
 
    location /dataroot/ {
    	internal;
    	alias /var/www/moodle/data;
    }
 
    location ~ [^/]\.php(/|$) {
        include snippets/fastcgi-php.conf;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
 
    }




  '';
  # defaultHTTPListenPort = 9001;
 };
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
 security.acme = {
	acceptTerms = true;
  defaults.email="nandarmath@gmail.com";
 };
 security.acme.certs = {
    # sesuaikan dengan hostname system nixos anda
	"localhost.io".email = "nandarmath@gmail.com";
 };
  services.phpfpm.phpOptions = ''
  date.timezone = "Asia/Jakarta";
  display_errors = off;
  upload_max_filesize = "100M";
  max_execution_time = 300;
  max_input_time = 300;
  memory_limit = 128M;
  post_max_size = 100M;
  max_file_uploads = 20;
  magic_quotes_gpc = Off;
  short_open_tag = Off;
  display_errors = Off;
  max_input_vars = 6000;
  extension=php_tidy.dll;
  '';

}

