{
  pkgs,
  lib,
  config,
  ...
}: let
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
            "custom/arrow6"
            "pulseaudio"
            "cpu"
            "memory"
            "disk"
            "temperature"
            "backlight"
            "idle_inhibitor"
            "custom/arrow7"
            "hyprland/window"
          ];
          modules-right = [
            "custom/arrow4"
            "network"
            "custom/arrow3"
            "custom/prayer_times"
            "custom/arrow3"
            "custom/notification"
            "custom/arrow3"
            "battery"
            "custom/arrow2"
            "tray"
            "custom/arrow1"
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
          "temperature" = {
            critical-threshold = 80;
            format = "{icon}{temperatureC}°C";
            format-alt = "{temperatureF}°F {icon}";
            format-icons = ["" "" ""];
            tooltip = false;
          };
          "backlight" = {
            device = "intel_backlight";
            format = "{icon}{percent}%";
            format-icons = ["" ""];
          };
          "clock" = {
            interval = 1;
            format =
              if clock24h == true
              then '' {:L%H:%M:%S %A,%d-%m-%Y}''
              else '' {:L%I:%M %p}'';
            tooltip = true;
            tooltip-format = "<big>{:%A,%d %B %Y }</big>\n<tt><small>{calendar}</small></tt>";
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
            max-length = 22;
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
            tooltip = true;
            tooltip-format = "{ipaddr}-{essid}({signalStrength}%)";
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
          "tray" = {
            spacing = 10;
          };
          "pulseaudio" = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}%";
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
            format = " ";
            on-click = "sleep 0.1 && wlogout";
          };
          "custom/startmenu" = {
            tooltip = false;
            format = "";
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
          "custom/arrow1" = {
            format = "";
          };
          "custom/arrow2" = {
            format = "";
          };
          "custom/arrow3" = {
            format = "";
          };
          "custom/arrow4" = {
            format = "";
          };
          "custom/arrow5" = {
            format = "";
          };
          "custom/arrow6" = {
            format = "";
          };
          "custom/arrow7" = {
            format = "";
          };
        }
      ];
      style = concatStrings [
        ''
          * {
            font-family: JetBrainsMono;
            font-size: 18px;
            border-radius: 0px;
            border: none;
            min-height: 0px;
          }
          window#waybar {
            background: #${config.lib.stylix.colors.base00};
            color: #${config.lib.stylix.colors.base05};
          }
          #workspaces button {
            padding: 0px 5px;
            background: transparent;
            color: #${config.lib.stylix.colors.base04};
          }
          #workspaces button.active {
            color: #${config.lib.stylix.colors.base08};
          }
          #workspaces button:hover {
            color: #${config.lib.stylix.colors.base08};
          }
          tooltip {
            background: #${config.lib.stylix.colors.base00};
            border: 1px solid #${config.lib.stylix.colors.base05};
            border-radius: 12px;
          }
          tooltip label {
            color: #${config.lib.stylix.colors.base05};
          }
          #window {
            padding: 0px 10px;
          }
          #pulseaudio, #cpu, #memory, #disk, #backlight, #temperature, #idle_inhibitor {
            padding: 0px 10px;
            background: #${config.lib.stylix.colors.base04};
            color: #${config.lib.stylix.colors.base00};
          }
          #custom-startmenu {
            color: #${config.lib.stylix.colors.base02};
            padding: 0px 14px;
            font-size: 20px;
            font-weight: bold;
            background: #${config.lib.stylix.colors.base0B};
          }
          #custom-hyprbindings, #network, #battery, #custom-prayer_times,
          #custom-notification, #custom-exit {
            background: #${config.lib.stylix.colors.base0F};
            color: #${config.lib.stylix.colors.base00};
            padding: 0px 10px;
          }
          #tray {
            background: #${config.lib.stylix.colors.base02};
            color: #${config.lib.stylix.colors.base04};
            padding: 0px 10px;
          }
          #clock {
            font-weight: bold;
            padding: 0px 10px;
            color: #${config.lib.stylix.colors.base00};
            background: #${config.lib.stylix.colors.base0E};
          }
          #custom-arrow1 {
            font-size: 24px;
            color: #${config.lib.stylix.colors.base0E};
            background: #${config.lib.stylix.colors.base02};
          }
          #custom-arrow2 {
            font-size: 24px;
            color: #${config.lib.stylix.colors.base02};
            background: #${config.lib.stylix.colors.base0F};
          }
          #custom-arrow3 {
            font-size: 24px;
            color: #${config.lib.stylix.colors.base00};
            background: #${config.lib.stylix.colors.base0F};
          }
          #custom-arrow4 {
            font-size: 24px;
            color: #${config.lib.stylix.colors.base0F};
            background: transparent;
          }
          #custom-arrow6 {
            font-size: 24px;
            color: #${config.lib.stylix.colors.base0B};
            background: #${config.lib.stylix.colors.base04};
          }
          #custom-arrow7 {
            font-size: 24px;
            color: #${config.lib.stylix.colors.base04};
            background: transparent;
          }
        ''
      ];
    };
  }
