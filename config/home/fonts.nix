{ config, pkgs, ... }:

{
  # Fonts are nice to have
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    roboto
    roboto-serif
    font-awesome
    open-sans
    liberation_ttf
    freefont_ttf
    dejavu_fonts
    unifont
    libertine
    corefonts
    # (nerd-fonts.override { fonts = [ "FiraCode" "Inconsolata" "Iosevka" "JetBrainsMono" "Meslo" "Noto" "RobotoMono" "Ubuntu" "UbuntuMono" ]; })
    iosevka
    fira-code-symbols
    jetbrains-mono
    icomoon-feather
    ubuntu_font_family
    helvetica-neue-lt-std
    amiri
  ];


}

