{ config, pkgs, ... }:

{
  # ... Opsi konfigurasi Anda yang lain bisa ada di sini ...

  # 1. KONFIGURASI FIREWALL
  # 2. KONFIGURASI DNS SERVER (BIND)
  services.bind = {
    enable = true;
    
    # Opsi keamanan, disesuaikan dengan jaringan 192.168.0.0/24
    extraOptions = ''
      acl "trusted" {
        127.0.0.1;
        192.168.0.0/24; // <-- Diperbarui
      };
      
      options {
        allow-query { any; };
        allow-recursion { trusted; };
        listen-on { any; };
        listen-on-v6 { any; };
      };
    '';

    # Definisi Zona DNS untuk domain "elmim.local"
    zones = {
      "elmim.local" = {
        type = "master";
        fileContent = ''
          $TTL 3600
          @       IN      SOA     ns1.elmim.local. admin.elmim.local. (
                                  2025090902 ; Serial (dinaikkan)
                                  8H         ; Refresh
                                  2H         ; Retry
                                  4W         ; Expire
                                  1H )       ; Negative Cache TTL
          
          ; Name Server
          @       IN      NS      ns1.elmim.local.
          
          ; Alamat IP untuk Name Server (laptop Anda)
          ns1     IN      A       192.168.0.222 ; <-- Diperbarui

          ; Contoh A Records (Hostname -> Alamat IPv4)
          router  IN      A       192.168.0.1
          server  IN      A       192.168.0.50
          nas     IN      A       192.168.0.60
          
          ; Contoh CNAME Records (Alias)
          gateway IN      CNAME   router.elmim.local.
        '';
      };

      # Zona Reverse DNS, disesuaikan untuk jaringan 192.168.0.x
      "0.168.192.in-addr.arpa" = { # <-- Diperbarui
        type = "master";
        fileContent = ''
          $TTL 3600
          @       IN      SOA     ns1.elmim.local. admin.elmim.local. (
                                  2025090902 ; Serial (dinaikkan)
                                  8H         ; Refresh
                                  2H         ; Retry
                                  4W         ; Expire
                                  1H )       ; Negative Cache TTL

          @       IN      NS      ns1.elmim.local.

          ; PTR Records (Alamat IP -> Hostname)
          222     IN      PTR     ns1.elmim.local.    ; 192.168.0.222
          1       IN      PTR     router.elmim.local.   ; 192.168.0.1
          50      IN      PTR     server.elmim.local.   ; 192.168.0.50
          60      IN      PTR     nas.elmim.local.      ; 192.168.0.60
        '';
      };
    };
  };

  # 3. KONFIGURASI DHCP SERVER
  services.dhcpd = {
    enable = true;
    # Menggunakan interface jaringan "enp0s3"
    interfaces = [ "enp0s3" ]; 
    
    # Definisi jaringan 192.168.0.0/24
    subnets."192.168.0.0" = { # <-- Diperbarui
      netmask = "255.255.255.0";
      option = {
        # Rentang (pool) alamat IP yang akan dibagikan ke klien
        range = [ "192.168.0.100" "192.168.0.200" ]; # <-- Range yang logis
        
        # Alamat IP router/gateway
        routers = [ "192.168.0.1" ]; # <-- Sesuaikan jika perlu

        # Otomatis memberikan alamat DNS Server ke semua klien
        domain-name-servers = [ 
          "192.168.0.222" # <-- IP Laptop NixOS Anda (DNS Utama)
          "1.1.1.1"        # <-- DNS Publik sebagai cadangan
        ];
      };
    };
  };

  # ... Opsi konfigurasi Anda yang lain bisa ada di sini ...
}
