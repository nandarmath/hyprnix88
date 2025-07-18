{
  pkgs,
  config,
  lib,
  ...
}:
let
  theme = config.lib.stylix.colors;
  inherit (import ../../../options.nix)
    stylixImage
    sdl-videodriver
    theKBDLayout
    theSecondKBDLayout
    ;
in
{
  home.packages = with pkgs; [
    swww
    grim
    slurp
    wl-clipboard
    swappy
    ydotool
    hyprpolkitagent
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };
    plugins = with pkgs.hyprlandPlugins; [
      hyprgrass
      hyprexpo
    ];
    settings = {
      exec-once = [
        # "xdg_sh"
        # "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"  # sementara digunakan sebelum diganti
        "systemctl --user start hyprpolkitagent"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "portalhyprland"
        # "systemctl --user stop xdg-desktop-portal-gtk"
        "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2"
        "hyprctl setcursor Bibata-Modern-Ice 24"
        # "killall -q swww;sleep .5 && swww init"
        "swww-daemon"
        "swww img ${stylixImage}"
        "pypr &"
        "keepassxc"
        # "wasistlos"
        "cloudflared tunnel run moodle"
        "iio-hyprland"
        "waybar"
        # "hyprpanel &"
        "sleep 1"
        # "eww daemon"
        # "eww open bar &"
        # "walker --gapplication-service"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "modprobe snd-aloop"
        "swaync"
        # "wallsetter"
        "nm-applet --indicator"
        # "swayidle -w timeout 720 'swaylock -f' timeout 800 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f -c 000000'"
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
        gaps_in = 4;
        gaps_out = 6;
        border_size = 5;
        # "col.active_border" = lib.mkForce "rgb(${theme.base08}) rgb(${theme.base0C}) 45deg";
        # "col.inactive_border" = lib.mkForce "rgb(${theme.base01})";
        "col.active_border" =
          lib.mkForce "rgba(${theme.base0C}ff) rgba(${theme.base0D}ff) rgba(${theme.base0B}ff) rgba(${theme.base0E}ff) 45deg";
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
        enable_anr_dialog = false;
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
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
      ];
    };
    extraConfig = "
      monitor=eDP-1,preferred,auto,1,transform,0
    ";

  };

  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../wallpapers;
      recursive = true;
    };
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };

}
