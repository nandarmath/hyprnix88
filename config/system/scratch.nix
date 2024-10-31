{ config, pkgs, ...}:
{
  nixpkgs.overlays = [    
    (self: super: 
      {
        google-chrome = (super.google-chrome.override (prev: rec{
          speechd = "";		
        })).overrideAttrs (oldAttrs: rec{
          name = "scratch";		
          src = super.fetchurl {	
            url = "https://github.com/redshaderobotics/scratch3.0-linux/releases/download/3.3.0/scratch-desktop_3.3.0_amd64.deb";
            #sha256 = "sha256-9nZjyJnXvOO1iZea3mdsj5FYkylrWnhColZ+q+X/xcU=";
            sha256 = "sha256-nIdzl3DkvGy9EsNS8nvPi8yK0gvx9mFaxYSxuYZZzxI=";
          };
        });    		
      }
    )
  ];

}

