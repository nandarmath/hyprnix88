{ config, pkgs, ... }:

{
  # Fonts are nice to have
  # home.packages = with pkgs; [
  #   noto-fonts
  #   noto-fonts-cjk-sans
  #   noto-fonts-emoji
  #   roboto
  #   roboto-serif
  #   font-awesome
  #   open-sans
  #   liberation_ttf
  #   freefont_ttf
  #   dejavu_fonts
  #   unifont
  #   (nerd-fonts.override { fonts = [ "FiraCode" "Inconsolata" "Iosevka" "JetBrainsMono" "Meslo" "Noto" "RobotoMono" "Ubuntu" "UbuntuMono" ]; })
  #   iosevka
  #   fira-code-symbols
  #   jetbrains-mono
  #   ubuntu_font_family
  #   helvetica-neue-lt-std
  # ];

  environment.systemPackages = with pkgs; [
    ];
    fonts.packages = with pkgs;[
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
    nerd-fonts.inconsolata
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.roboto-mono
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    ];

}

