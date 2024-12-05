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
#    hyprplugins.hyprtrails
#    hyprplugins.hyprbars
     #inputs.hyprgrass.packages.${pkgs.system}.default
    ];
    extraConfig = let
      modifier = "SUPER";
    in concatStrings [ ''
      monitor=,preferred,auto,1
      windowrule = float, ^(steam)$
      windowrule = size 1080 900, ^(steam)$
      windowrule = center, ^(steam)$
      general {
        gaps_in = 2
        gaps_out = 4
        border_size = 4
        col.active_border = rgba(${theme.base0C}ff) rgba(${theme.base0D}ff) rgba(${theme.base0B}ff) rgba(${theme.base0E}ff) 45deg
        col.inactive_border = rgba(${theme.base00}cc) rgba(${theme.base01}cc) 45deg
        layout = dwindle
        resize_on_border = true
      }

      input {
        kb_layout = ${theKBDLayout}, ${theSecondKBDLayout}
	      kb_options = grp:alt_shift_toggle
        #kb_options=caps:super
        follow_mouse = 1
        touchpad {
          natural_scroll = false
        }
        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        accel_profile = flat
        touchdevice {
          enabled = true
        }
      }
      env = NIXOS_OZONE_WL, 1
      env = NIXPKGS_ALLOW_UNFREE, 1
      env = XDG_CURRENT_DESKTOP,Hyprland
      # env = XDG_CURRENT_DESKTOP,sway
      env = XDG_SESSION_TYPE,wayland
      env = XDG_SESSION_DESKTOP,Hyprland
      env = GDK_BACKEND,wayland,x11
      env = CLUTTER_BACKEND,wayland
      env = SDL_VIDEODRIVER,${sdl-videodriver}
      env = XCURSOR_SIZE, 24
      env = XCURSOR_THEME,Bibata-Modern-Ice
      env = QT_QPA_PLATFORM,wayland;xcb
      #env = QT_QPA_PLATFORM,xcb
      env = QT_QPA_PLATFORMTHEME,qt6ct
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
        workspace_swipe_touch = true

      }
      misc {
        mouse_move_enables_dpms = true
        key_press_enables_dpms = false
        disable_hyprland_logo = true
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
            size = 3
            passes = 3
            new_optimizations = on
            ignore_opacity = on
        }
      }
      plugin {
     #  hyprtrails {
     #    color = rgba(${theme.base0A}ff)
     #  }
     #  hyprbars {
     #    bar_height = 17
     #    hyprbars-button = rgba(${theme.base0A}ff), 10, 󰖭, hyprctl dispatch killactive
     #    hyprbars-button = rgb(eeee11), 10, ,, hyprctl dispatch fullscreen 1
     #    bar_buttons_alignment = left
     #  }
        touch_gestures {
         # swipe left from right edge
         hyprgrass-bind = , edge:r:l, workspace, +1

         # swipe up from bottom edge
         hyprgrass-bind = , edge:d:u, exec, firefox

         # swipe down from left edge
         hyprgrass-bind = , edge:l:d, exec, pactl set-sink-volume @DEFAULT_SINK@ -4%

         # swipe down with 4 fingers
         # NOTE: swipe events only trigger for finger count of >= 3
         hyprgrass-bind = , swipe:4:d, killactive

         # swipe diagonally left and down with 3 fingers
         # l (or r) must come before d and u
         hyprgrass-bind = , swipe:3:ld, exec, thunar

         # tap with 3 fingers
         # NOTE: tap events only trigger for finger count of >= 3
         hyprgrass-bind = , tap:3, exec, kitty

         # longpress can trigger mouse binds:
         hyprgrass-bindm = , longpress:2, movewindow
         hyprgrass-bindm = , longpress:3, resizewindow
         }


      }

      exec-once = $POLKIT_BIN
      exec-once = xdg_sh
      exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once = systemctl --user stop xdg-desktop-portal-gtk
      exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      exec-once = hyprctl setcursor Bibata-Modern-Ice 24
      exec-once = swww init
      exec-once = pypr
      exec-once = cloudflared tunnel run moodle 
      # exec-once = ags
      #exec-once = hyprbars
      exec-once = nwg-dock-hyprland -d -mb 10 -ml 10 -mr 10 -x -c "rofi -show drun"
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
        new_status = true
      }
      bind = ${modifier},Q,exec,${terminal} -e fish
      bind = ${modifier},RETURN,exec,kitty -e fish
      bind = ${modifier},A,exec,rofi-launcher
      bind = ${modifier}SHIFT,W,exec,web-search
      bind = ${modifier}SHIFT,F,exec,rofi -show filebrowser
      bind = ${modifier}SHIFT,S,exec,swaync-client -rs
      ${if browser == "google-chrome" then ''
    	bind = ${modifier},W,exec,google-chrome-stable
      '' else ''
	    bind = ${modifier},W,exec,[workspace 2 silent]${browser}
      ''}
      bind = ${modifier}, minus, movetoworkspace,special
      bind = ${modifier}, equal, togglespecialworkspace
      bind = ${modifier},M,exec,emopicker9000
      bind = ${modifier},N,exec,joplin-desktop
      bind = ${modifier}CONTROL,N,exec, kitty -e joplin --profile ~/.config/joplin-desktop
      bind = ${modifier},S,exec,screenshootin
      #bind = ${modifier}SHIFT,exec, ~/hyprnix/config/home/files/womic.sh
      bind = ${modifier},D,exec,discord
      bind = ${modifier},R,exec,libreoffice --writer
      bind = ${modifier},C,exec,libreoffice --calc
      bind = ${modifier},T,exec,[workspace 9 silent] telegram-desktop
      bind = ${modifier},K,exec, rofi -show calc -modi calc -no-show-match -no-sort
      bind = ${modifier},B,exec, rofi-bluetooth
      bind = ${modifier},Y,exec,kitty -e ytfzf -t
      bind = ${modifier},I,exec,${terminal} -e syncthing
      bind = ${modifier},O,exec,obs
      bind = ${modifier},G,exec,gimp
      bind = ${modifier}SHIFT,G,exec, fish -c record_scree_gif
      bind = ${modifier},E,exec,thunar
      bind = ${modifier},TAB,exec,window-selector
      bind = ${modifier}SHIFT,E,exec,${terminal} -e yazi
      bind = ${modifier}SHIFT,Y,exec,spotify
      bind = ${modifier},X,killactive,
      bind = ${modifier},P,pseudo,
      bind = ${modifier}CONTROL,P,exec,monitor-projection
      bind = ${modifier},Z,exec, rofi -show power-menu -modi power-menu:rofi-power-menu
      bind = ${modifier}SHIFT,I,togglesplit,
      bind = ${modifier},F,fullscreen,
      bind = ${modifier},V,exec,cliphist list | rofi -dmenu | cliphist decode | wl-copy
      bind = ${modifier},Space,togglefloating,
      bind = ${modifier}SHIFT,P,exec, hyprpicker --autocopy
      bind = ${modifier}SHIFT,C,exec,${terminal} -e kalker
      bind = ${modifier}SHIFT,Z,exec, pypr zoom
      bind = ${modifier}SHIFT,A,exec, pypr expose
      bind = ${modifier}CONTROL,C,exec,[move 879 48; size 1031 638]${terminal} -e calcure
      bind = CONTROL, TAB,exec, hyprnome --cycle
      bind = ${modifier}SHIFT,N,exec, sh ~/hyprnix/config/home/files/dmenu_iptv
      bind = ${modifier}SHIFT,left,movewindow,l
      bind = ${modifier}SHIFT,right,movewindow,r
      bind = ${modifier}SHIFT,up,movewindow,u
      bind = ${modifier}SHIFT,down,movewindow,d
      bind = ${modifier}SHIFT,h,movewindow,l
      bind = ${modifier}SHIFT,l,movewindow,r
      bind = ${modifier}SHIFT,k,movewindow,u
      bind = ${modifier}SHIFT,j,movewindow,d
      bind = ${modifier}SHIFT,R,exec,pkill wf-recorder
      bind = ${modifier}SHIFT,M,exec,dmenu-mager
      bind = ${modifier}SHIFT,S,exec,rofi-pulse-select sink
      bind = ${modifier}ALT,S,exec,rofi-pulse-select source
      bind = ${modifier}ALT,R,exec,wf-recorder --audio --file=$HOME/videos/$(date +Rec%d%m%Y_%Hh%Mm%Ss.mp4)
      bind = ${modifier}CONTROL,R,exec,wf-recorder -c h264_vaapi -g "$(slurp)" --audio --file=$HOME/Videos/$(date +Rec%d%m%Y_%Hh%Mm%Ss.mp4)
      bind = ${modifier}SHIFT,L,exec,wf-recorder -c h264_vaapi --muxer=v4l2 --codec=rawvideo --file=/dev/video2 -x yuv420p
      bind = ${modifier},left,movefocus,l
      bind = ${modifier},right,movefocus,r
      bind = ${modifier},up,movefocus,u
      bind = ${modifier},down,movefocus,d
      bind = ${modifier},U,exec,rofi-systemd
      bind = ,Print,exec,grim
      bind = ${modifier},print,exec,grim -g "$(slurp)" - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
      bind = ${modifier}SHIFT,O,exec,grim -g "$(slurp $SLURP_ARGS)" "tmp.png" && tesseract "tmp.png" - | wl-copy && rm "tmp.png"
      bind = ${modifier}SHIFT,T,exec,grim -g "$(slurp $SLURP_ARGS)" "tmp.png" && tesseract --oem 3 -l ind "tmp.png" - | wl-copy && rm "tmp.png"
      bind = ${modifier}ALT, T, exec,terjemah
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
      bind = ${modifier}CONTROL,1,workspace,11
      bind = ${modifier}CONTROL,2,workspace,12
      bind = ${modifier}CONTROL,3,workspace,13
      bind = ${modifier}CONTROL,4,workspace,14
      bind = ${modifier}CONTROL,5,workspace,15
      bind = ${modifier}CONTROL,6,workspace,16
      bind = ${modifier}CONTROL,7,workspace,17
      bind = ${modifier}CONTROL,8,workspace,18
      bind = ${modifier}CONTROL,9,workspace,19
      bind = ${modifier}CONTROL,0,workspace,20
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
      bind = CONTROLALT,1,movetoworkspace,11 
      bind = CONTROLALT,2,movetoworkspace,12 
      bind = CONTROLALT,3,movetoworkspace,13
      bind = CONTROLALT,4,movetoworkspace,14
      bind = CONTROLALT,5,movetoworkspace,15
      bind = CONTROLALT,6,movetoworkspace,16
      bind = CONTROLALT,7,movetoworkspace,17
      bind = CONTROLALT,8,movetoworkspace,18
      bind = CONTROLALT,9,movetoworkspace,19
      bind = CONTROLALT,0,movetoworkspace,20
      bind = ${modifier}SHIFT,1,movetoworkspacesilent,1
      bind = ${modifier}SHIFT,2,movetoworkspacesilent,2
      bind = ${modifier}SHIFT,3,movetoworkspacesilent,3
      bind = ${modifier}SHIFT,4,movetoworkspacesilent,4
      bind = ${modifier}SHIFT,5,movetoworkspacesilent,5
      bind = ${modifier}SHIFT,6,movetoworkspacesilent,6
      bind = ${modifier}SHIFT,7,movetoworkspacesilent,7
      bind = ${modifier}SHIFT,8,movetoworkspacesilent,8
      bind = ${modifier}SHIFT,9,movetoworkspacesilent,9
      bind = ${modifier}SHIFT,0,movetoworkspacesilent,10
      bind = ${modifier}ALT,X,exec,hyprctl reload
      bind = ${modifier}CONTROL,right,workspace,e+1
      bind = ${modifier}CONTROL,left,workspace,e-1
      bind = ${modifier},mouse_down,workspace, e+1
      bind = ${modifier},mouse_up,workspace, e-1
      bindm = ${modifier},mouse:272,movewindow
      bindm = ${modifier},mouse:273,resizewindow
      bind = ${modifier}ALT,right, resizeactive, 20 0
      bind = ${modifier}ALT,left, resizeactive, -20 0
      bind = ${modifier}ALT,N, exec, sticky
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

      # set layout
      bind = ${modifier}ALT, m, exec, hyprctl --batch 'keyword general:layout master'
      bind = ${modifier}ALT, d, exec, hyprctl --batch 'keyword general:layout dwindle'
      bind = ${modifier}SHIFT, B, exec, hyprctl getoption plugin:hyprbars:nobar


      bind = SUPER,F4,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,F5,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,F6,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,F7,pass,^(com\.obsproject\.Studio)$
      bind = ALT,F10,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,F8,pass,^(com\.obsproject\.Studio)$
      bind = ALT,F9,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,RBRACKET,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,APOSTROPHE,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,LBRACKET,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,SEMICOLON,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,comma,pass,^(com\.obsproject\.Studio)$
      bind = SUPER,period,pass,^(com\.obsproject\.Studio)$


      windowrulev2 = opacity 0.7 0.7,floating:1
      windowrulev2 = opacity 0.7 0.7,class:^(Alacritty)$
      windowrulev2 = opacity 0.8 0.8,class:^(kitty)$
      windowrule = size 700 550,class:^(Alacritty)$
      windowrulev2 = float,class:^(Alacritty)$
      windowrulev2 = float,class:^("Quick Format Citation")$
      windowrulev2 = float,class:^(file-roller)$
      windowrulev2 = float,class:^(timeshift-gtk)$
      windowrulev2 = float,class:^(sticky.py)$
      windowrulev2 = float,class:^(GoldenDict-ng)$
      windowrulev2 = float,class:^(GParted)$
      windowrulev2 = float,class:^(nwg-look)$
      windowrulev2 = float,class:^(ristretto)$
      windowrulev2 = float,class:^(pavucontrol)$
      windowrulev2 = float,title:^(Media viewer)$
      windowrulev2 = float,title:^(Add/Edit Citation)$
      windowrulev2 = float,title:^(TelegramDesktop)$
      windowrulev2 = float,class:^(xdm-app)$
      windowrule = size 600 450,class:^(Add/Edit Citation)$
      windowrule = size 700 550,class:^(TelegramDesktop)$
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
      windowrulev2=move 0 0,title:^(flameshot)
      #windowrulev2=nofullscreenrequest,title:^(flameshot)

      windowrulev2 = workspace 2 silent,class:^(brave-browser)
      windowrulev2 = workspace 2 silent,class:^(firefox)
      windowrulev2 = workspace 2 silent,class:^(chromium-browser)
      windowrulev2 = workspace 9 silent,title:^(web.whatsapp.com)
      windowrulev2 = workspace 8 silent,class:^(brave-youtube.com__-Default)
      windowrulev2 = workspace 7 silent,class:^(libreoffice-calc)
      windowrulev2 = workspace 6 silent,class:^(libreoffice-writer)
      windowrulev2 = workspace 5 silent,class:^(libreoffice-impress)








    '' ];
  };
}
