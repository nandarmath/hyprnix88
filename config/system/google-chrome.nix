{ config, pkgs, ...}:
{
  nixpkgs.overlays = [    
    (self: super: 
      {
        google-chrome = (super.google-chrome.override (prev: rec{
          speechd = "";		
        })).overrideAttrs (oldAttrs: rec{
          name = "google-chrome";		
          src = super.fetchurl {	
            url = "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb";
            #sha256 = "sha256-9nZjyJnXvOO1iZea3mdsj5FYkylrWnhColZ+q+X/xcU=";
            sha256 = "sha256-nIdzl3DkvGy9EsNS8nvPi8yK0gvx9mFaxYSxuYZZzxI=";
          };
        });    		
      }
    )
  ];

}
