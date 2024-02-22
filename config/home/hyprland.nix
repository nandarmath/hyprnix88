{ pkgs, config, lib, inputs, ... }:

let
  theme = config.colorScheme.palette;
  hyprplugins = inputs.hyprland-plugins.packages.${pkgs.system};
  inherit (import ../../options.nix) 
    browser cpuType gpuType
    wallpaperDir borderAnim
    theKBDLayout terminal
    theSecondKBDLayout
    theKBDVariant sdl-videodriver;
in with lib; {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = [
      # hyprplugins.hyprtrails
    ];
    extraConfig = let
      modifier = "SUPER";
    in concatStrings [ ''
      monitor=,preferred,auto,1
      windowrule = float, ^(steam)$
      windowrule = size 1080 900, ^(steam)$
      windowrule = center, ^(steam)$
      general {
        gaps_in = 6
        gaps_out = 8
        border_size = 2
        col.active_border = rgba(${theme.base0C}ff) rgba(${theme.base0D}ff) rgba(${theme.base0B}ff) rgba(${theme.base0E}ff) 45deg
        col.inactive_border = rgba(${theme.base00}cc) rgba(${theme.base01}cc) 45deg
        layout = dwindle
        resize_on_border = true
      }

      input {
        kb_layout = ${theKBDLayout}, ${theSecondKBDLayout}
	kb_options = grp:alt_shift_toggle
        kb_options=caps:super
        follow_mouse = 1
        touchpad {
          natural_scroll = false
        }
        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        accel_profile = flat
      }
      env = NIXOS_OZONE_WL, 1
      env = NIXPKGS_ALLOW_UNFREE, 1
      env = XDG_CURRENT_DESKTOP,Hyprland
      env = XDG_SESSION_TYPE,wayland
      env = XDG_SESSION_DESKTOP,Hyprland
      env = GDK_BACKEND,wayland,x11
      env = CLUTTER_BACKEND,wayland
      env = SDL_VIDEODRIVER,${sdl-videodriver}
      env = XCURSOR_SIZE, 24
      env = XCURSOR_THEME,Bibata-Modern-Ice
      #env = QT_QPA_PLATFORM,wayland;xcb
      env = QT_QPA_PLATFORM,xcb
      env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      env = QT_AUTO_SCREEN_SCALE_FACTOR,1
      env = MOZ_ENABLE_WAYLAND,1
      env = MOZ_DRM_DEVICE,/dev/dri/renderD128
      ${if cpuType == "vm" then ''
        env = WLR_NO_HARDWARE_CURSORS,1
        env = WLR_RENDERER_ALLOW_SOFTWARE,1
      '' else ''
      ''}
      ${if gpuType == "nvidia" then ''
        env = WLR_NO_HARDWARE_CURSORS,1
      '' else ''
      ''}
      gestures {
        workspace_swipe = true
        workspace_swipe_fingers = 3
      }
      misc {
        mouse_move_enables_dpms = true
        key_press_enables_dpms = false
      }
      animations {
        enabled = yes
        bezier = wind, 0.05, 0.9, 0.1, 1.05
        bezier = winIn, 0.1, 1.1, 0.1, 1.1
        bezier = winOut, 0.3, -0.3, 0, 1
        bezier = liner, 1, 1, 1, 1
        animation = windows, 1, 6, wind, slide
        animation = windowsIn, 1, 6, winIn, slide
        animation = windowsOut, 1, 5, winOut, slide
        animation = windowsMove, 1, 5, wind, slide
        animation = border, 1, 1, liner
        ${if borderAnim == true then ''
          animation = borderangle, 1, 30, liner, loop
        '' else ''
        ''}
        animation = fade, 1, 10, default
        animation = workspaces, 1, 5, wind
      }
      decoration {
        rounding = 10
        drop_shadow = false
        blur {
            enabled = true
            size = 5
            passes = 3
            new_optimizations = on
            ignore_opacity = on
        }
      }
      plugin {
        hyprtrails {
          color = rgba(${theme.base0A}ff)
        }
      }
      exec-once = $POLKIT_BIN
      exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      exec-once = hyprctl setcursor Bibata-Modern-Ice 24
      exec-once = swww init
      exec-once = waybar
      exec-once = wl-paste --type text --watch cliphist store #Stores only text data
      exec-once = wl-paste --type image --watch cliphist store #Stores only image data
      exec-once = modprobe snd-aloop
      exec-once = swaync
      exec-once = wallsetter
      exec-once = nm-applet --indicator
      exec-once = swayidle -w timeout 720 'swaylock -f' timeout 800 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f -c 000000'
      dwindle {
        pseudotile = true
        preserve_split = true
      }
      master {
        new_is_master = true
      }
      bind = ${modifier},Q,exec,${terminal} -e fish
      bind = ${modifier},A,exec,rofi-launcher
      bind = ${modifier}SHIFT,W,exec,web-search
      bind = ${modifier}SHIFT,S,exec,swaync-client -rs
      ${if browser == "google-chrome" then ''
	bind = ${modifier},W,exec,google-chrome-stable
      '' else ''
	bind = ${modifier},W,exec,${browser}
      ''}
      bind = ${modifier},M,exec,emopicker9000
      bind = ${modifier},S,exec,screenshootin
      #bind = ${modifier}SHIFT,exec, ~/zaneyos/config/home/files/womic.sh
      bind = ${modifier},D,exec,discord
      bind = ${modifier},R,exec,libreoffice --writer
      bind = ${modifier},C,exec,libreoffice --calc
      bind = ${modifier},T,exec,telegram-desktop
      bind = ${modifier},K,exec, rofi -show calc -modi calc -no-show-match -no-sort
      bind = ${modifier},B,exec, rofi-bluetooth
      bind = ${modifier},Y,exec,kitty -e ytfzf -t
      bind = ${modifier},I,exec,${terminal} -e syncthing
      bind = ${modifier},O,exec,obs
      bind = ${modifier},G,exec,gimp
      #bind = ${modifier}SHIFT,G,exec,godot4
      bind = ${modifier}SHIFT,G,exec,${terminal} -e tgpt
      bind = ${modifier},E,exec,thunar
      #bind = ${modifier},TAB,exec,rofi -show window
      bind = ${modifier},TAB,exec,sh ~/zaneyos/config/home/files/cwindows.sh
      bind = ${modifier}SHIFT,Y,exec,spotify
      bind = ${modifier},X,killactive,
      bind = ${modifier},P,pseudo,
      bind = ${modifier},Z,exec, rofi -show power-menu -modi power-menu:rofi-power-menu
      bind = ${modifier}SHIFT,I,togglesplit,
      bind = ${modifier},F,fullscreen,
      bind = ${modifier},V,exec,cliphist list | rofi -dmenu | cliphist decode | wl-copy
      bind = ${modifier},Space,togglefloating,
      bind = ${modifier}SHIFT,P,exec, hyprpicker --autocopy
      bind = ${modifier}SHIFT,C,exit,
      bind = ${modifier}SHIFT,left,movewindow,l
      bind = ${modifier}SHIFT,right,movewindow,r
      bind = ${modifier}SHIFT,up,movewindow,u
      bind = ${modifier}SHIFT,down,movewindow,d
      bind = ${modifier}SHIFT,h,movewindow,l
      bind = ${modifier}SHIFT,l,movewindow,r
      bind = ${modifier}SHIFT,k,movewindow,u
      bind = ${modifier}SHIFT,j,movewindow,d
      bind = ${modifier}SHIFT,R,exec,pkill wf-recorder
      bind = ${modifier}SHIFT,M,exec,rofi-mpd
      bind = ${modifier}SHIFT,S,exec,rofi-pulse-select sink
      bind = ${modifier}ALT,S,exec,rofi-pulse-select source
      bind = ${modifier}ALT,R,exec,wf-recorder --audio --file=$HOME/videos/$(date +Rec%Y%m%d_%Hh%Mm%Ss.mp4)
      bind = ${modifier}CONTROL,R,exec,wf-recorder -g "$(slurp)" --audio --file=$HOME/Videos/$(date +Rec%Y%m%d_%Hh%Mm%Ss.mp4)
      bind = ${modifier},left,movefocus,l
      bind = ${modifier},right,movefocus,r
      bind = ${modifier},up,movefocus,u
      bind = ${modifier},down,movefocus,d
      bind = ${modifier},h,movefocus,l
      bind = ${modifier},l,movefocus,r
      bind = ${modifier},k,movefocus,u
      bind = ${modifier},j,movefocus,d
      bind = ${modifier},1,workspace,1
      bind = ${modifier},2,workspace,2
      bind = ${modifier},3,workspace,3
      bind = ${modifier},4,workspace,4
      bind = ${modifier},5,workspace,5
      bind = ${modifier},6,workspace,6
      bind = ${modifier},7,workspace,7
      bind = ${modifier},8,workspace,8
      bind = ${modifier},9,workspace,9
      bind = ${modifier},0,workspace,10
      bind = ALT,1,movetoworkspace,1
      bind = ALT,2,movetoworkspace,2
      bind = ALT,3,movetoworkspace,3
      bind = ALT,4,movetoworkspace,4
      bind = ALT,5,movetoworkspace,5
      bind = ALT,6,movetoworkspace,6
      bind = ALT,7,movetoworkspace,7
      bind = ALT,8,movetoworkspace,8
      bind = ALT,9,movetoworkspace,9
      bind = ALT,0,movetoworkspace,10
      bind = ${modifier}CONTROL,right,workspace,e+1
      bind = ${modifier}CONTROL,left,workspace,e-1
      bind = ${modifier},mouse_down,workspace, e+1
      bind = ${modifier},mouse_up,workspace, e-1
      bindm = ${modifier},mouse:272,movewindow
      bindm = ${modifier},mouse:273,resizewindow
      bind = ALT,Tab,cyclenext
      bind = ALT,Tab,bringactivetotop
      bind = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bind = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      binde = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = ,XF86MonBrightnessDown,exec,brightnessctl set 5%-
      bind = ,XF86MonBrightnessUp,exec,brightnessctl set +5%

      # Multi Monitor
      bind = SUPERCONTROL,PERIOD,exec, hyprctl --batch 'keyword monitor eDP-1,highres,0x0,1; keyword monitor HDMI-A-1,1920x1080,1920x0,1'
      bind = SUPERCONTROL,COMMA, exec, hyprctl --batch 'keyword monitor HDMI-A-1,1920x1080,0x0,1; keyword monitor eDP-1,highres,1920x0,1'
      bind = SUPERCONTROL,m, exec, hyprctl --batch 'keyword monitor eDP-1,highres,0x0,1;keyword monitor HDMI-A-1,1920x1080,0x0,1,mirror,eDP-1'
      bind = SUPERCONTROL,d, exec, hyprctl --batch 'keyword monitor HDMI-A-1,1920x1080,1920x0,1;' && sleep 1 && hyprctl --batch 'keyword monitor eDP-1,disable'
      bind = SUPERCONTROL,SPACE, exec, hyprctl --batch 'keyword monitor eDP-1,highres,0x0,1; keyword monitor HDMI-A-1,disable'





      bind = SUPERCONTROL,F6,pass,^(com\.obsproject\.Studio)$
      bind = SUPERCONTROL,F7,pass,^(com\.obsproject\.Studio)$
      bind = SUPERCONTROL,F10,pass,^(com\.obsproject\.Studio)$
      bind = SUPERCONTROL,F8,pass,^(com\.obsproject\.Studio)$
      bind = SUPERCONTROL,F9,pass,^(com\.obsproject\.Studio)$
      bind = CONTROLSHIFT,RBRACKET,pass,^(com\.obsproject\.Studio)$
      bind = CONTROLSHIFT,APOSTROPHE,pass,^(com\.obsproject\.Studio)$
      bind = CONTROLSHIFT,LBRACKET,pass,^(com\.obsproject\.Studio)$
      bind = CONTROLSHIFT,SEMICOLON,pass,^(com\.obsproject\.Studio)$


      windowrulev2 = float,class:^(file-roller)$
      windowrulev2 = float,class:^(timeshift-gtk)$
      windowrulev2 = float,class:^(GParted)$
      #windowrulev2 = float,class:^(com.obsproject.Studio)$
      #windowrule = float, ^(totem)$
      #windowrule = float, ^(lollypop)$
      windowrulev2 = float,class:^(nwg-look)$
      windowrulev2 = float,class:^(ristretto)$
      #windowrule = float, ^(io.github.celluloid_player.Celluloid)$
      windowrulev2 = float,class:^(pavucontrol)$
      windowrulev2 = float,title:^(Media viewer)$
      windowrulev2 = float,title:^(Volume Control)$
      windowrulev2 = float,title:^(Picture-in-Picture)$
      windowrulev2 = float,class:^(file_progress)$
      windowrulev2 = float,class:^(confirm)$
      windowrulev2 = float,class:^(dialog)$
      windowrulev2 = float,class:^(download)$
      windowrulev2 = float,class:^(notification)$
      windowrulev2 = float,class:^(error)$
      windowrulev2 = float,class:^(confirmreset)$
      windowrulev2 = float,title:^(Open File)$
      windowrulev2 = float,title:^(branchdialog)$
      windowrulev2 = float,title:^(Confirm to replace files)
      windowrulev2 = float,title:^(File Operation Progress)











    '' ];
  };
}
