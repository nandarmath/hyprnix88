{ lib, config, pkgs, ... }:
let
  app = "myApp";
  appDomain = "nixos.local";
  dataDir = "/var/www/html";
in
{
services.nginx = {
    enable = true;
    user = "nandar";
    group ="users";
    eventsConfig = ''
      worker_connections 10240;
      use epoll;
      multi_accept on;
    '';
    clientMaxBodySize = "100m";
    virtualHosts = {
      ${appDomain} = {
        root = "${dataDir}";
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
            index index.php;
        '';
        locations."/".extraConfig =''
            try_files $uri $uri/ = 404;
        '';
        locations."~ ^(.+\\.php)(.*)$".extraConfig = ''
            fastcgi_split_path_info  ^(.+\.php)(.*)$;
            fastcgi_index            index.php;
            fastcgi_pass             unix:${config.services.phpfpm.pools.${app}.socket};
            include                  ${config.services.nginx.package}/conf/fastcgi_params;
            fastcgi_param  PATH_INFO        $fastcgi_path_info;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            # if(!-f $document_root$fastcgi_script_name) {return 404;}
            # include ${pkgs.nginx}/conf/fastcgi.conf;            
          '';
        # locations."/dataroot/".extraConfig =''
        #     internal;
        #     alias /var/www/moodledata/; # ensure the path ends with /
        #   '';
        };
      };
    
  
};


  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
#    settings = { "mysqld" = { "port" = 3308; }; };
    initialScript =
      pkgs.writeText "initial-script" ''
        CREATE USER IF NOT EXISTS 'root'@'localhost' IDENTIFIED BY 'root';
        CREATE DATABASE IF NOT EXISTS wordpress;
        GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';
      '';
    ensureDatabases = [ "wordpress" ];
    ensureUsers = [
      {
        name = "root";
        ensurePermissions = {
          "root.*" = "ALL PRIVILEGES";
          "*.*" = "ALL PRIVILEGES";
        };
      }
    ];
 };
 services.longview.mysqlPasswordFile = "/run/keys/mysql.password";

security.acme = {
	acceptTerms = true;
};
security.acme.certs = {
    # sesuaikan dengan hostname system nixos anda
	${appDomain}.email = "nandarmath@gmail.com";
};
  
  services.phpfpm.pools.${app} = {
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
networking.extraHosts = ''
  127.0.0.1   local.nixos
  127.0.0.1   moodle.nixos
  '';

}

