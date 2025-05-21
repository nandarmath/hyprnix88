{...}: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
      plugin {
        touch_gestures {
           # swipe left from right edge
           hyprgrass-bind = , swipe:2:l, workspace, +1

           # swipe left from right edge
           hyprgrass-bind = , swipe:2:r, workspace, -1

           # swipe down from up  edge
           hyprgrass-bind = , edge:u:d, exec, pkill wvkbd-mobintl

           # swipe up from bottom edge
           hyprgrass-bind = , edge:d:u, exec, wvkbd-mobintl -H 300 -L 350 --alpha 100

           # swipe down from left edge
           hyprgrass-bind = , edge:l:d, exec, pactl set-sink-volume @DEFAULT_SINK@ -4%

           # swipe down from left edge
           hyprgrass-bind = , edge:l:u, exec, pactl set-sink-volume @DEFAULT_SINK@ +4%

           # swipe down with 4 fingers
           # NOTE: swipe events only trigger for finger count of >= 3
           hyprgrass-bind = , swipe:4:d, killactive

           # swipe diagonally left and down with 3 fingers
           # l (or r) must come before d and u
           hyprgrass-bind = , swipe:3:ld, exec, thunar

           # tap with 4 fingers
           # NOTE: tap events only trigger for finger count of >= 3
           hyprgrass-bind = , tap:4, exec, dmenu-mager

           # tap with 3 fingers
           # NOTE: tap events only trigger for finger count of >= 3
           hyprgrass-bind = , tap:3, exec, rofi -show drun

           # tap with 2 fingers
           # NOTE: tap events only trigger for finger count of >= 3
           hyprgrass-bind = , tap:2, exec, return
           
           # longpress can trigger mouse binds:
           hyprgrass-bindm = , longpress:2, movewindow
           hyprgrass-bindm = , longpress:3, resizewindow
         }
      }
    '';
  };
}
