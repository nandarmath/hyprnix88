{ config, pkgs, ... }:
let
  app = "myApp";
  appDomain = "elmim.lc";
  dataDir = "/var/www/html/lms";
in
{
services.nginx = {
    enable = true;
    user = "nandar";
    group ="users";
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
    mapHashMaxSize = 2048;
    appendConfig = ''
      worker_processes 4;
      worker_rlimit_nofile 65535;

    '';
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
        # sslCertificate = "/home/nandar/hyprnix/config/system/secret/nixos.loca.pem";
        # sslCertificateKey = "/home/nandar/hyprnix/config/system/secret/nixos.loca-key.pem";
        extraConfig = ''
            index index.php;
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
          '';
        };
      };
    
  
};

## Mariadb
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
 
## Postresql
services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    settings = {
        # pool_mode = "session";
        # max_client_conn =  300;
        # default_pool_size = 50;
        # server_round_robin = 0;
        max_connections = 200;
        shared_buffers = "3GB";
        effective_cache_size = "9GB";
        maintenance_work_mem = "768MB";
        checkpoint_completion_target = 0.9;
        wal_buffers = "16MB";
        default_statistics_target = 100;
        random_page_cost = 1.1;
        effective_io_concurrency = 200;
        work_mem = "5242kB";
        huge_pages = "off";
        min_wal_size = "1GB";
        max_wal_size = "4GB";
        max_worker_processes = 6;
        max_parallel_workers_per_gather = 3;
        max_parallel_workers = 6;
        max_parallel_maintenance_workers = 3;
        };
  };
  
  
## Redis
services.redis = {
  enable = true;
  package = pkgs.redis;
  servers."nandar" = {
    enable = true;
    # port = 6379;
    # bind = "127.0.0.1";
    requirePass = "@Nandar88";
    
  };
};
  
 

## SSL
security.acme = {
	acceptTerms = true;
};
security.acme.certs = {
    # sesuaikan dengan hostname system nixos anda
	${appDomain}.email = "nandarmath@gmail.com";
};
  
  ## Php-fpm
  services.phpfpm.phpPackage = pkgs.php;
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
    phpPackage =config.services.phpfpm.phpPackage;
  };
  
  ## PHP.ini
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
  session.save_handler = redis;
  session.save_path = "tcp://127.0.0.1:6379?auth=@Nandar88";
session.use_strict_mode = 0;
session.use_cookies = 1;
session.use_only_cookies = 1;
session.name = PHPSESSID;
session.auto_start = 0;
session.cookie_lifetime = 0;
session.cookie_path = /;
session.cookie_domain =;
session.cookie_httponly =;
session.cookie_samesite =;
session.serialize_handler = php;
session.gc_probability = 0;
session.gc_divisor = 1000;
session.gc_maxlifetime = 1440;
session.referer_check =;
session.cache_limiter = nocache;
session.cache_expire = 180;
session.use_trans_sid = 0;
session.sid_length = 26;
session.trans_sid_tags = "a=href,area=href,frame=src,form=";
session.sid_bits_per_character = 5;
zend.assertions = -1;
tidy.clean_output = Off;
soap.wsdl_cache_enabled=1;
soap.wsdl_cache_dir="/tmp";
soap.wsdl_cache_ttl=86400;
soap.wsdl_cache_limit = 5;
ldap.max_links = -1;
opcache.enable=1;
opcache.memory_consumption=128;
opcache.max_accelerated_files=10000;
opcache.use_cwd=1;
opcache.validate_timestamps=1;
opcache.revalidate_freq=30;
opcache.save_comments=1;
opcache.enable_file_override=0;
  
  '';
  
  ## Hosts
networking.extraHosts = ''
  127.0.0.1   local.nixos
  127.0.0.1   moodle.nixos
  '';
  
  

}

