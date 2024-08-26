{pkgs,config, ...}:
{
services.httpd = {
  enable = false;
  package = pkgs.apacheHttpd;
  enablePHP = true;
  phpPackage = pkgs.php;
  user = "nandar";
  group="users";
  };
# security.acme.certs.defaults.email="nandarsigma06@gmail.com";
services.httpd.virtualHosts = {
  "chamilo.lc" = {
    documentRoot = "/home/nandar/WebApp/chamilo";
    extraConfig = ''
      Timeout 600
		ProxyTimeout 600

		Alias /chamilo "/home/nandar/WebApp/chamilo/"
		DirectoryIndex index.php index.html index.htm
		<Directory "/home/nandar/WebApp/chamilo/">
			Options FollowSymLinks
			AllowOverride All
			DirectoryIndex index.php
			Require all granted
		</Directory>

    '';
    listen =[
      {
      ip = "*";
      port=81;
      } ];
    };
  "moodle.lc" = {
    # enableACME = true;
    # forceSSL = true;
    documentRoot = "/home/nandar/WebApp/moodle";
    extraConfig = ''
      Timeout 600
		ProxyTimeout 600

		Alias /moodle "/home/nandar/WebApp/moodle/"
		DirectoryIndex index.php index.html index.htm
		<Directory "/home/nandar/WebApp/moodle/">
			Options FollowSymLinks
			AllowOverride All
			DirectoryIndex index.php
			Require all granted
		</Directory>

    '';
    listen =[
      {
      ip = "*";
      port=82;
      } ];
    };
  };
services.httpd.phpOptions = ''
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
# services.mysql.enable = true;
# services.mysql.package = pkgs.mariadb;
}
