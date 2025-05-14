# PLEASE READ THE WIKI FOR DETERMINING
# VALUES FOR THIS PAGE.
# https://gitlab.com/Zaney/zaneyos/-/wikis/Setting-Options
let
  username = "nandar";
  hostname = "nixos";
  userHome = "/home/${username}";
  flakeDir = "${userHome}/hyprnix";
in {
  # User Variables
  username = "${username}";
  hostname = "${hostname}";
  gitUsername = "nandarsigma06";
  gitEmail = "nandarsigma06@gmail.com";
  theme = "catppuccin-macchiato";
  # slickbar = if waybarStyle == "slickbar" then true else false;
  # simplebar = if waybarStyle == "simplebar" then true else false;
  borderAnim = true;
  bar-number = true;
  waybarAnim = true;
  waybarChoice = ./config/home/waybar/waybar-simple.nix;
  browser = "floorp";
  # ^ (use as is or replace with your own repo - removing will break the wallsetter script)
  screenshotDir = "${userHome}/Pictures/Screenshots";
  flakeDir = "${flakeDir}";
  terminal = "alacritty";
  stylixImage = ./config/wallpapers/bg08.jpg;

  # Set Animation style
  # Available options are:
  # animations-def.nix  (default)
  # animations-end4.nix (end-4 project)
  # animations-dynamic.nix (ml4w project)
  # animations-kaku.nix (kaku project)
  animChoice = ./config/home/hyprland/animations-end4.nix;
  # System Settings
  clock24h = true;
  theLocale = "en_US.UTF-8";
  theKBDLayout = "us";
  theSecondKBDLayout = "us";
  theKBDVariant = "";
  theLCVariables = "id_ID.UTF-8";
  theTimezone = "Asia/Jakarta";
  theShell = "fish"; # Possible options: bash, zsh
  theKernel = "cachyos"; # Possible options: default, latest, lqx, xanmod, zen
  # This is for running NixOS
  # On a tmpfs or root on RAM
  # You Most Like Want This -> false
  impermanence = true; # This should be set to false unless you know what your doing!
  sdl-videodriver = "x11"; # Either x11 or wayland ONLY. Games might require x11 set here
  # For Hybrid Systems intel-nvidia
  # Should Be Used As gpuType
  cpuType = "intel";
  gpuType = "intel";

  # Nvidia Hybrid Devices
  # ONLY NEEDED FOR HYBRID
  # SYSTEMS!
  intel-bus-id = "PCI:0:2:0";
  nvidia-bus-id = "PCI:14:0:0";

  # Enable / Setup NFS
  nfs = false;
  nfsMountPoint = "/mnt/nas";
  nfsDevice = "nas:/volume1/nas";

  # NTP & HWClock Settings
  ntp = true;
  localHWClock = false;

  # Enable Printer & Scanner Support
  printer = true;

  # Enable Flatpak & Larger Programs
  flatpak = true;
  kdenlive = true;
  blender = true;

  # Enable Support For
  # Logitech Devices
  logitech = true;

  # Enable Terminals
  # If You Disable All You Get Kitty
  wezterm = false;
  alacritty = true;
  kitty = true;

  # Enable Python & PyCharm
  python = true;
}
