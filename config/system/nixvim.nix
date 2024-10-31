{config, ... }:
let 
helpers = config.lib.nixvim;
in
{
  programs.nixvim ={ 
    enable = true;
    imports = [ ./nixvim/plugins];
  };

  imports = [
    ./nixvim
  ];







}
