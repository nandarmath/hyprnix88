{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  theme = config.lib.stylix.colors;
  inherit
    (import ../../../options.nix)
    stylixImage
    theKBDLayout
    theSecondKBDLayout
    sdl-videodriver
    ;
in
  with lib; {
    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "$POLKIT_BIN"
          "xdg_sh"
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user stop xdg-desktop-portal-gtk"
          "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2"
          "hyprctl setcursor Bibata-Modern-Ice 24"
          # "killall -q swww;sleep .5 && swww init"
          "swww init"
          "sleep 1.5 && swww img ${stylixImage}"
          "pypr &"
          "keepassxc"
          "wasistlos"
          "cloudflared tunnel run moodle"
          "iio-hyprland"
          "nwg-dock-hyprland -x -p 'bottom' -l 'top' -i 32 -hd 10 -mt 10 -mb 10 -ml 5 -c 'rofi -show drun' -d"
          "waybar"
          # "eww daemon"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "modprobe snd-aloop"
          "swaync"
          # "wallsetter"
          "nm-applet --indicator"
          "swayidle -w timeout 720 'swaylock -f' timeout 800 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f -c 000000'"
        ];

        input = {
          kb_layout = "${theKBDLayout}, ${theSecondKBDLayout}";
          kb_options = [
            "grp:alt_shift_toggle"
          ];
          #kb_options=caps:super
          follow_mouse = 1;
          touchpad = {
            natural_scroll = false;
            disable_while_typing = true;
          };
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          # accel_profile = flat;
          touchdevice = {
            enabled = true;
          };
        };

        master = {
          new_status = true;
        };

        general = {
          "$mod" = "SUPER";
          gaps_in = 5;
          gaps_out = 6;
          border_size = 6;
          # "col.active_border" = lib.mkForce "rgb(${theme.base08}) rgb(${theme.base0C}) 45deg";
          # "col.inactive_border" = lib.mkForce "rgb(${theme.base01})";
          "col.active_border" = lib.mkForce "rgba(${theme.base0C}ff) rgba(${theme.base0D}ff) rgba(${theme.base0B}ff) rgba(${theme.base0E}ff) 45deg";
          "col.inactive_border" = lib.mkForce "rgba(${theme.base00}cc) rgba(${theme.base01}cc) 45deg";
          layout = "dwindle";
          resize_on_border = true;
        };
        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
          workspace_swipe_touch = true;
        };

        misc = {
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = false;
          disable_hyprland_logo = true;
          # layers_hog_keyboard_focus = true;
          # initial_workspace_tracking = 0;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = true;
          };
          shadow = {
            enabled = true;
            range = 24;
          };
        };

        windowrulev2 = [
          "tag +file-manager, class:^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
          "tag +terminal, class:^(Alacritty|kitty|kitty-dropterm)$"
          "tag +browser, class:^(Brave-browser(-beta|-dev|-unstable)?)$"
          "tag +browser, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
          "tag +browser, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
          "tag +browser, class:^([Tt]horium-browser|[Cc]achy-browser)$"
          "tag +projects, class:^(codium|codium-url-handler|VSCodium)$"
          "tag +projects, class:^(VSCode|code-url-handler)$"
          "tag +im, class:^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
          "tag +im, class:^([Ff]erdium)$"
          "tag +im, class:^([Ww]hatsapp-for-linux)$"
          "tag +im, class:^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
          "tag +im, class:^(teams-for-linux)$"
          "tag +games, class:^(gamescope)$"
          "tag +games, class:^(steam_app_\d+)$"
          "tag +gamestore, class:^([Ss]team)$"
          "tag +gamestore, title:^([Ll]utris)$"
          "tag +gamestore, class:^(com.heroicgameslauncher.hgl)$"
          "tag +settings, class:^(gnome-disks|wihotspot(-gui)?)$"
          "tag +settings, class:^([Rr]ofi)$"
          "tag +settings, class:^(file-roller|org.gnome.FileRoller)$"
          "tag +settings, class:^(nm-applet|nm-connection-editor|blueman-manager)$"
          "tag +settings, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
          "tag +settings, class:^(nwg-look|qt5ct|qt6ct|[Yy]ad)$"
          "tag +settings, class:(xdg-desktop-portal-gtk)"
          "move 72% 7%,title:^(Picture-in-Picture)$"
          "center, class:^([Ff]erdium)$"
          "center, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
          "center, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
          "center, title:^(Authentication Required)$"
          "idleinhibit fullscreen, class:^(*)$"
          "idleinhibit fullscreen, title:^(*)$"
          "idleinhibit fullscreen, fullscreen:1"
          "float, tag:settings*"
          "float, class:^([Ff]erdium)$"
          "float, title:^(Picture-in-Picture)$"
          "float, class:^(com.github.rafostar.Clapper)$"
          "float, title:^(Authentication Required)$"
          "float, class:(codium|codium-url-handler|VSCodium), title:negative:(.*codium.*|.*VSCodium.*)"
          "float, class:^(com.heroicgameslauncher.hgl)$, title:negative:(Heroic Games Launcher)"
          "float, class:^([Ss]team)$, title:negative:^([Ss]team)$"
          "float, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
          "float, initialTitle:(Add Folder to Workspace)"
          "float, initialTitle:(Open Files)"
          "float, initialTitle:(wants to save)"
          "float, class:^('Quick Format Citation')$"
          "float, class:^(file-roller)$"
          "float, class:^(Alacritty)$"
          "float, class:^(org.keepassxc.KeePassXC)$"
          "size 1080 560, class:^(org.keepassxc.KeePassXC)$"
          "size 700 550,class:^(Alacritty)$"
          "size 600 450,class:^(Add/Edit Citation)$"
          "size 700 550,class:^(TelegramDesktop)$"
          "size 70% 60%, initialTitle:(Open Files)"
          "size 60% 50%, initialTitle:(rofi - Kalker)"
          "size 70% 60%, initialTitle:(Add Folder to Workspace)"
          "size 70% 70%, tag:settings*"
          "size 60% 70%, class:^([Ff]erdium)$"
          "opacity 1.0 1.0, tag:browser*"
          "opacity 0.9 0.8, tag:projects*"
          "opacity 0.94 0.86, tag:im"
          "opacity 0.9 0.8, tag:file-manager*"
          "opacity 0.8 0.7, tag:terminal*"
          "opacity 0.8 0.7, tag:settings*"
          "opacity 0.8 0.7, class:^(gedit|org.gnome.TextEditor|mousepad)$"
          "opacity 0.9 0.8, class:^(seahorse)$ # gnome-keyring gui"
          "opacity 0.95 0.75, title:^(Picture-in-Picture)$"
          "pin, title:^(Picture-in-Picture)$"
          "keepaspectratio, title:^(Picture-in-Picture)$"
          "noblur, tag:games*"
          "fullscreen, tag:games*"
          "workspace 2 silent,class:^(brave-browser)"
          "workspace 2 silent,class:^(zen-alpha)"
          "workspace 2 silent,class:^(firefox)"
          "workspace 2 silent,class:^(chromium-browser)"
          "workspace 9 silent,title:^(WasIstLos)"
          "workspace 8 silent,class:^(brave-youtube.com__-Default)"
          "workspace 7 silent,class:^(libreoffice-calc)"
          "workspace 6 silent,class:^(libreoffice-writer)"
          "workspace 5 silent,class:^(libreoffice-impress)"
          "workspace 10 silent,class:^(org.keepassxc.KeePassXC)"
          "pin,title:^(KeePassXC - Browser Access Request)"
          "tile,  class:^(libreoffice.*)$"
          "noshadow, floating:0"
          # "shadow, floating:1"
        ];
        workspace = [
          "11, rounding:false, decorate:false"

        ];
        env = [
          "NIXOS_OZONE_WL, 1"
          "NIXPKGS_ALLOW_UNFREE, 1"
          "XDG_CURRENT_DESKTOP, Hyprland"
          "XDG_SESSION_TYPE, wayland"
          "XDG_SESSION_DESKTOP, Hyprland"
          "GDK_BACKEND, wayland, x11"
          "CLUTTER_BACKEND, wayland"
          "QT_QPA_PLATFORM=wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
          "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
          "SDL_VIDEODRIVER, x11"
          "MOZ_ENABLE_WAYLAND, 1"
          "SDL_VIDEODRIVER,${sdl-videodriver}"
          "XCURSOR_SIZE, 24"
          "XCURSOR_THEME,Bibata-Modern-Ice"
          "QT_QPA_PLATFORMTHEME,qt6ct"
          "MOZ_DRM_DEVICE,/dev/dri/renderD128"
        ];
      };

      extraConfig = "
      monitor=eDP-1,preferred,auto,1,transform,0
    ";
    };
  }
