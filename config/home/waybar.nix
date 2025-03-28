{ pkgs, config, lib, host, ... }:

let
  palette = config.colorScheme.palette;
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
  inherit (import ../../options.nix) bar-number clock24h waybarAnim;
in with lib; {
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [{
      layer = "top";
      position = "top";

      modules-center = [ "hyprland/workspaces" ] ;
      modules-left = [ "custom/startmenu" "pulseaudio" "cpu" "memory" "disk" "hyprland/window" ];
      modules-right = [ "temperature" "custom/weather" "network" "idle_inhibitor" "custom/notification" "battery" "clock" "tray" "group/powermenu"];

      "hyprland/workspaces" = {
      	format = if bar-number == true then "{name}" else "{icon}";
      	format-icons = {
          default = " ";
          active = " ";
          urgent = " ";
      	};
      	on-scroll-up = "hyprctl dispatch workspace e+1";
      	on-scroll-down = "hyprctl dispatch workspace e-1";
      };
      "clock" = {
	format = if clock24h == true then '' {:L%H:%M}'' 
	else '' {:L%I:%M %p}'';
      	tooltip = true;
	tooltip-format = "<big>{:%A, %d.%B %Y }</big><tt><small>{calendar}</small></tt>";
      };
      "hyprland/window" = {
      	max-length = 25;
        separate-outputs = false;
        rewrite = { "" = " 🙈 No Windows? "; };
      };
      "memory" = {
      	interval = 5;
      	format = " {}%";
        tooltip = true;
      };
      "custom/weather" = {
        exec = "/home/nandar/hyprnix/config/home/get_weather.sh";
        return-type = "json";
        format = "{}";
        tooltip = true;
        interval = 3600;
      };
      "temperature"= {
        critical-threshold= 80;
        format = "{icon} {temperatureC}°C";
        format-alt = "{temperatureF}°F {icon}";
        format-icons = ["" "" ""];
        tooltip = false;
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
        format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        format-ethernet = " {bandwidthDownOctets}";
        format-wifi = "{icon} {bandwidthUpBytes}|{bandwidthDownBytes}";
        format-disconnected = "󰤮";
        tooltip = false;
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
          default = ["" "" ""];
        };
        on-click = "sleep 0.1 && pavucontrol";
      };
      "custom/themeselector" = {
        tooltip = false;
        format = "";
        on-click = "sleep 0.1 && theme-selector";
      };
      "custom/startmenu" = {
        tooltip = false;
        format = "  ";
        # exec = "rofi -show drun";
        on-click = "sleep 0.1 && rofi-launcher";
      };
      "custom/hyprbindings" = {
        tooltip = false;
        format = " Bindings";
        on-click = "sleep 0.1 && list-hypr-bindings";
      };
      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
            activated = " ";
            deactivated = " ";
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
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        on-click = "";
        tooltip = false;
      };

      "group/powermenu" = {
          drawer = {
            children-class = "powermenu-child";
            transition-duration = 300;
            transition-left-to-right = false;
          };
          modules = [
            "custom/power"
            "custom/exit"
            "custom/lock"
            "custom/suspend"
            "custom/reboot"
          ];
          orientation = "inherit";
        };
      "custom/power" = {
          format = "󰐥";
          on-click = "${pkgs.systemd}/bin/systemctl poweroff";
          tooltip = false;
        };
        "custom/exit" = {
          format = "󰈆";
          on-click = "${pkgs.systemd}/bin/loginctl terminate-user $USER";
          tooltip = false;
        };
        "custom/lock" = {
          format = "󰌾";
          on-click = "${pkgs.systemd}/bin/loginctl lock-session";
          tooltip = false;
        };
        "custom/suspend" = {
          format = "󰤄";
          on-click = "${pkgs.systemd}/bin/systemctl suspend";
          tooltip = false;
        };
        "custom/reboot" = {
          format = "󰜉";
          on-click = "${pkgs.systemd}/bin/systemctl reboot";
          tooltip = false;
        };
    }];
    style = concatStrings [''
      * {
	font-size: 16px;
	font-family: JetBrainsMono Nerd Font, Font Awesome, sans-serif;
    	font-weight: bold;
      }
      window#waybar {
	      background-color: transparent;
	      border-bottom: 1px solid rgba(26,27,38,0);
	      border-radius: 0px;
	      color: #${palette.base0F};
      }
      #workspaces {
       background: #${palette.base01};
       margin: 2px;
       padding: 0px 1px;
       border-radius: 15px;
       border: 0px;
       font-style: normal;
       color: #${palette.base00};
      }
      #workspaces button {
	     padding: 0px 5px;
	     margin: 4px 3px;
	     border-radius: 10px;
	     border: 0px;
	     color: #${palette.base00};
          background: linear-gradient(45deg, #${palette.base0E}, #${palette.base0F}, #${palette.base0D}, #${palette.base09});
          background-size: 300% 300%;
          ${if waybarAnim == true then ''
            animation: gradient_horizontal 15s ease infinite;
          '' else '' 
          ''}
       opacity: 0.5;
          transition: ${betterTransition};
      }
      #workspaces button.active {
       padding: 0px 5px;
       margin: 4px 3px;
       border-radius: 10px;
       border: 0px;
       color: #${palette.base00};
             background: linear-gradient(45deg, #${palette.base0E}, #${palette.base0F}, #${palette.base0D}, #${palette.base09});
             background-size: 300% 300%;
             ${if waybarAnim == true then ''
               animation: gradient_horizontal 15s ease infinite;
             '' else '' 
             ''}
             transition: ${betterTransition};
       opacity: 1.0;
       min-width: 40px;
      }
      #workspaces button:hover {
       border-radius: 10px;
       color: #${palette.base00};
             background: linear-gradient(45deg, #${palette.base0E}, #${palette.base0F}, #${palette.base0D}, #${palette.base09});
             background-size: 300% 300%;
             ${if waybarAnim == true then ''
               animation: gradient_horizontal 15s ease infinite;
             '' else '' 
             ''}
       opacity: 0.8;
             transition: ${betterTransition};
         }
         @keyframes gradient_horizontal {
         0% {
           background-position: 0% 50%;
         }
         50% {
           background-position: 100% 50%;
         }
         100% {
           background-position: 0% 50%;
         }
             }
             @keyframes swiping {
               0% {
           background-position: 0% 200%;
         }
         100% {
           background-position: 200% 200%;
         }
         }
      tooltip {
      background: #${palette.base00};
      border: 1px solid #${palette.base0E};
      border-radius: 10px;
      }
      tooltip label {
    	color: #${palette.base07};
      }
      #window {
	     margin: 4px;
	     padding: 2px 10px;
	     color: #${palette.base05};
	     background: #${palette.base01};
	     border-radius: 10px;
      }
      #memory {
     	color: #${palette.base0F};
      background: #${palette.base01};
      margin: 4px;
      padding: 2px 10px;
      border-radius: 10px;
      }
      #clock {
    	color: #${palette.base01};
        background: linear-gradient(45deg, #${palette.base0C}, #${palette.base0F}, #${palette.base0B}, #${palette.base08});
        background-size: 300% 300%;
        ${if waybarAnim == true then ''
          animation: gradient_horizontal 15s ease infinite;
        '' else '' 
        ''}
        margin: 4px;
        padding: 2px 10px;
        border-radius: 10px;
      }
      #cpu {
      	color: #${palette.base07};
        background: #${palette.base01};
        margin: 4px;
        padding: 2px 10px;
        border-radius: 10px;
      }
      #disk {
    	color: #${palette.base08};
      background: #${palette.base01};
      margin: 4px;
      padding: 2px 10px;
      border-radius: 10px;
      }
      #battery {
    	color: #${palette.base08};
      background: #${palette.base01};
      margin: 4px;
      padding: 2px 10px;
      border-radius: 10px;
      }
      #network {
    	color: #${palette.base09};
      background: #${palette.base01};
      margin: 4px;
      padding: 2px 10px;
      border-radius: 10px;
      }
      #custom-hyprbindings {
    	color: #${palette.base0E};
      background: #${palette.base01};
      margin: 4px;
      padding: 2px 10px;
      border-radius: 10px;
      }
      #custom-weather {
    	color: #${palette.base0E};
      background: #${palette.base01};
      margin: 4px;
      padding: 2px 10px;
      border-radius: 10px;
      }
      #tray {
    	color: #${palette.base05};
      background: #${palette.base01};
      margin: 4px;
      padding: 2px 10px;
      border-radius: 10px;
      }
      #pulseaudio {
    	color: #${palette.base0D};
       background: #${palette.base01};
       margin: 4px;
       padding: 2px 10px;
       border-radius: 10px;
      }
      #custom-notification {
    	color: #${palette.base0C};
      background: #${palette.base01};
      margin: 4px;
      padding: 2px 10px;
      border-radius: 10px;
      }

      #temperature {
    	  color: #${palette.base0C};
	      background: #${palette.base01};
	      margin: 4px;
	      padding: 2px 10px;
	      border-radius: 10px;
      }
      #custom-themeselector {
        color: #${palette.base0D};
        background: #${palette.base01};
        margin: 4px;
        padding: 2px 10px;
        border-radius: 10px;
      }
      #custom-startmenu {
    	  color: #${palette.base00};
        background: linear-gradient(45deg, #${palette.base09}, #${palette.base03}, #${palette.base0C}, #${palette.base07});
        background-size: 300% 300%;
        ${if waybarAnim == true then ''
          animation: gradient_horizontal 15s ease infinite;
        '' else '' 
        ''}
        margin: 4px;
        padding: 2px 10px;
        border-radius: 10px;
      }
      #idle_inhibitor {
    	  color: #${palette.base09};
	      background: #${palette.base01};
	      margin: 4px;
	      padding: 2px 10px;
	      border-radius: 10px;
        }
      #custom-exit,
      #custom-power,
      #custom-lock,
      #custom-reboot,
      #custom-suspend{
        color: #${palette.base0E};
	      background: #${palette.base01};
	      border-radius: 10px;
	      margin: 4px;
	      padding: 2px 10px;
        }
      ''
    ];
  };
}
