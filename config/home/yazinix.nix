{ pkgs, ... }:
with pkgs;
{

  programs = {
    yazi = {
      enable = true;
      settings = {
        log = {
          enabled = false;
        };
        mgr = {
          ratio = [
            2
            4
            3
          ];
          show_hidden = false;
          sort_by = "alphabetical";
          linemode = "size";
          sort_dir_first = true;
          sort_reverse = false;
        };
        preview = {
          tab_size = 4;
          image_filter = "nearest";
          max_width = 1920;
          max_height = 1080;
          image_quality = 90;
        };
        opener = {
          edit = [
            {
              run = ''$EDITOR "$@"'';
              block = true;
              desc = "edit";
              for = "unix";
            }
          ];
          compress-zip = [
            {
              run = ''${ouch}/bin/ouch compress "$@" "$@.zip"'';
              desc = "compress zip";
              for = "unix";
            }
          ];
          compress-gzip = [
            {
              run = ''${ouch}/bin/ouch compress "$@" "$@.tar.gz"'';
              desc = "compress tar.gz";
              for = "unix";
            }
          ];
          encrypt = [
            {
              run = ''${gnupg}/bin/gpg -c "$@"'';
              desc = "encrypt";
              for = "unix";
            }
          ];
          decrypt = [
            {
              run = ''${gnupg}/bin/gpg "$@"'';
              desc = "decrypt";
              for = "unix";
            }
          ];
          open = [
            {
              run = ''${xdg-utils}/bin/xdg-open "$@"'';
              desc = "open";
              for = "linux";
            }
          ];
          reveal = [
            {
              run = ''${xdg-utils}/bin/xdg-open $(dirname "$1")'';
              desc = "reveal";
              for = "linux";
            }
          ];
          extract = [
            {
              run = ''${ouch}/bin/ouch decompress "$@"'';
              desc = "extract";
              for = "unix";
            }
          ];
          play = [
            {
              run = ''${mpv}/bin/mpv "$@"'';
              orphan = true;
              desc = "play";
              for = "unix";
            }
          ];
        };
        open = {
          rules = [
            {
              name = "*/";
              use = [
                "edit"
                "compress-zip"
                "compress-gzip"
                "open"
                "reveal"
              ];
            }
            {
              mime = "text/*";
              use = [
                "edit"
                "reveal"
              ];
            }
            {
              mime = "image/*";
              use = [
                "open"
                "reveal"
              ];
            }
            {
              mime = "{audio,video}/*";
              use = [
                "play"
                "reveal"
              ];
            }
            {
              name = "*.kra";
              use = [
                "open"
                "reveal"
              ];
            }
            {
              name = "*.blend";
              use = [
                "open"
                "reveal"
              ];
            }
            {
              mime = "application/{json,ndjson}";
              use = [
                "edit"
                "reveal"
              ];
            }
            {
              mime = "*/javascript";
              use = [
                "edit"
                "reveal"
              ];
            }
            {
              mime = "inode/empty";
              use = [
                "edit"
                "reveal"
              ];
            }
            {
              mime = "application/pdf";
              use = [
                "open"
                "reveal"
              ];
            }
            {
              mime = "application/epub+zip";
              use = [
                "open"
                "reveal"
              ];
            }
            {
              name = "*.gpg";
              use = [
                "decrypt"
                "reveal"
              ];
            }
            {
              mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
              use = [
                "extract"
                "open"
                "encrypt"
                "reveal"
              ];
            }
            {
              name = "*";
              use = [
                "edit"
                "reveal"
              ];
            }
          ];
        };
      };
    };
  };
}
