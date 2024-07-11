{config, pkgs, ...}:
{

  # Nginx 
  services.nginx = {
    enable = true;
    package = pkgs.nginxStable;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    #virtualHosts."localhost".listen = [ { addr = "127.0.0.1"; port = 80; } ];
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
    
    virtualHost.listen = [];
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
