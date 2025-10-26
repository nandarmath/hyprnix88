{
  pkgs,
  lib,
  config,
  ...
}: let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  inherit (import ../../../options.nix) clock24h;
in
  with lib; {
    # Configure & Theme Waybar
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = [
        {
          layer = "top";
          position = "top";
          modules-center = ["hyprland/workspaces"];
          modules-left = [
            "custom/startmenu"
            "pulseaudio"
            "cpu"
            "memory"
            "temperature"
            "disk"
            "idle_inhibitor"
            "hyprland/window"
          ];
          modules-right = [
            "custom/prayer_times"
            "network"
            "group/notifmenu"
            "battery"
            "tray"
            "clock"
            "custom/exit"
          ];

          "hyprland/workspaces" = {
            format = "{name}";
            format-icons = {
              default = " ";
              active = " ";
              urgent = " ";
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          "clock" = {
            interval = 1;
            format =
              if clock24h == true
              then '' {:L%H:%M:%S}''
              else '' {:L%I:%M %p}'';
            tooltip = true;
            tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                days = "<span color='#ecc6d9'><b>{}</b></span>";
                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = "tz_up";
              on-scroll-down = "tz_down";
            };
            on-click = "sleep 0.1 && kitty -e calcure";
          };
          "hyprland/window" = {
            max-length = 18;
            separate-outputs = false;
            rewrite = {
              "" = " 🙈 No Windows? ";
            };
          };
          "memory" = {
            interval = 5;
            format = " {}%";
            tooltip = true;
          };
          "cpu" = {
            interval = 5;
            format = " {usage:2}%";
            tooltip = true;
          };
          "temperature"= {
            critical-threshold= 80;
            format = "{icon} {temperatureC}°C";
            format-alt = "{temperatureF}°F {icon}";
            format-icons = ["" "" ""];
            tooltip = false;
          };
           "custom/prayer_times" = {
            format = " {}";
            tooltip = true;
            interval = 60;
            exec = "prayer_time";
            return-type = "json";
            on-click = "notify-send \"Waktu Sholat Kab. Sleman\" \"$(jq -r '.tooltip' $HOME/.cache/prayer_times.json | sed 's/\\\\n/\\n/g')\"";
            # on-click = "notify-send \"Waktu Sholat $(jq -r '.location' $HOME/.cache/prayer_times/prayer_times.json)\" \"$(jq -r '.tooltip' $HOME/.cache/prayer_times/prayer_times.json | sed 's/\\\\n/\\n/g')\"";
            # on-click-right = get_location;
          };
          "group/notifmenu" = {
          drawer = {
            children-class = "notifmenu-child";
            transition-duration = 300;
            transition-left-to-right = false;
          };
          modules = [
            "custom/timer"
            "custom/notification"
            "custom/screenrecorder"
            "custom/weather"
          ];
          orientation = "inherit";
        };

          "disk" = {
            format = " {free}";
            tooltip = true;
          };
          "network" = {
            format-icons = [
              "󰤯"
              "󰤟"
              "󰤢"
              "󰤥"
              "󰤨"
            ];
            format-ethernet = " {bandwidthDownOctets}";
            # format-wifi = "{icon} {signalStrength}%";
            format-wifi = "{icon} {bandwidthUpBytes}|{bandwidthDownBytes}";
            format-disconnected = "󰤮";
            tooltip = false;
          };
          
          "custom/weather" = {
            exec = "/home/nandar/hyprnix/config/home/get_weather.sh";
            return-type = "json";
            format = "{}";
            tooltip = true;
            interval = 3600;
          };
          "tray" = {
            spacing = 12;
          };
          "pulseaudio" = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "sleep 0.1 && pavucontrol";
          };
          "custom/exit" = {
            tooltip = false;
            format = "";
            on-click = "sleep 0.1 && wlogout";
          };
          "custom/startmenu" = {
            tooltip = false;
            format = "";
            # exec = "rofi -show drun";
            on-click = "sleep 0.1 && rofi-launcher";
          };
          "custom/hyprbindings" = {
            tooltip = false;
            format = "󱕴";
            on-click = "sleep 0.1 && list-keybinds";
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
            tooltip = "true";
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon} {}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "sleep 0.1 && task-waybar";
            escape = true;
          };

        "custom/timer" = {
          tooltip = true;
          return-type = "json";
          exec = "waybar-timer check";
          on-click = "waybar-timer minute_dialog";
          on-click-right = "waybar-timer datetime_dialog";
          on-click-middle = "waybar-timer stop";
          interval = 1;
        };

        "custom/screenrecorder"=  {
          exec = "screenrecorder status";
          interval = "once";
          signal = 1;
          return-type = "json";
          tooltip = true;
          format = "{}";
          on-click = "screenrecorder toggle fullscreen";
          on-click-right = "screenrecorder toggle region";
        };


          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󱘖 {capacity}%";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            on-click = "";
            tooltip = false;
          };
        }
      ];
      style = concatStrings [
        ''
          * {
            font-family: JetBrainsMono Nerd Font Mono;
            font-size: 14px;
            border-radius: 0px;
            border: none;
            min-height: 0px;
          }
          window#waybar {
            background: rgba(0,0,0,0);
          }
          #workspaces {
            color: #${config.lib.stylix.colors.base00};
            background: #${config.lib.stylix.colors.base01};
            margin: 4px 4px;
            padding: 5px 5px;
            border-radius: 16px;
          }
          #workspaces button {
            font-weight: bold;
            padding: 0px 5px;
            margin: 0px 3px;
            border-radius: 16px;
            color: #${config.lib.stylix.colors.base00};
            background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
            opacity: 0.5;
            transition: ${betterTransition};
          }
          #workspaces button.active {
            font-weight: bold;
            padding: 0px 5px;
            margin: 0px 3px;
            border-radius: 16px;
            color: #${config.lib.stylix.colors.base00};
            background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
            transition: ${betterTransition};
            opacity: 1.0;
            min-width: 40px;
          }
          #workspaces button:hover {
            font-weight: bold;
            border-radius: 16px;
            color: #${config.lib.stylix.colors.base00};
            background: linear-gradient(45deg, #${config.lib.stylix.colors.base08}, #${config.lib.stylix.colors.base0D});
            opacity: 0.8;
            transition: ${betterTransition};
          }
          tooltip {
            background: #${config.lib.stylix.colors.base00};
            border: 1px solid #${config.lib.stylix.colors.base08};
            border-radius: 12px;
          }
          tooltip label {
            color: #${config.lib.stylix.colors.base08};
          }
          #window, #pulseaudio, #cpu, #memory, #temperature, #disk, #idle_inhibitor {
            font-weight: bold;
            margin: 4px 0px;
            margin-left: 7px;
            padding: 0px 18px;
            background: #${config.lib.stylix.colors.base06};
            color: #${config.lib.stylix.colors.base00};
            border-radius: 24px 1px 24px 1px;
            border-bottom: 2px solid #${config.lib.stylix.colors.base09};
            border-right: 2px solid #${config.lib.stylix.colors.base09};
          }
          #custom-startmenu {
            color: #${config.lib.stylix.colors.base09};
            background: #${config.lib.stylix.colors.base02};
            font-size: 28px;
            margin: 0px;
            padding: 0px 30px 0px 15px;
            border-radius: 0px 0px 40px 0px;
          }
          #custom-hyprbindings, #network, #battery,
          #custom-notification, #tray, #clock, #custom-weather, #custom-prayer_times, #custom-timer, #custom-screenrecorder {
            font-weight: bold;
            background: #${config.lib.stylix.colors.base09};
            color: #${config.lib.stylix.colors.base00};
            margin: 4px 0px;
            margin-right: 7px;
            border-radius: 1px 24px 1px 24px;
            padding: 0px 18px;
            border-bottom: 2px solid #${config.lib.stylix.colors.base00};
            border-left: 2px solid #${config.lib.stylix.colors.base00};
          }
          #custom-timer.active {
            background-color: #CF2430;
          }
          #custom-exit {
            font-weight: bold;
            color: #0D0E15;
            background: linear-gradient(90deg, #${config.lib.stylix.colors.base0E}, #${config.lib.stylix.colors.base0C});
            margin: 0px;
            padding: 0px 15px 0px 30px;
            font-size: 28px;
            border-radius: 0px 0px 0px 40px;
          }
        ''
      ];
    };
  }
