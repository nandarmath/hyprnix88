{ config, pkgs, ... }:

{
  # Fonts are nice to have
  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    roboto
    roboto-serif
    font-awesome
    open-sans
    liberation_ttf
    freefont_ttf
    dejavu_fonts
    unifont
    (nerdfonts.override { fonts = [ "FiraCode" "Inconsolata" "Iosevka" "JetBrainsMono" "Meslo" "Noto" "RobotoMono" "Ubuntu" "UbuntuMono" ]; })
    fira-code
    fira-code-symbols
    inconsolata
    iosevka
    jetbrains-mono
    meslo-lg
    ubuntu_font_family
  ];
}

