{ pkgs ? import <nixpkgs> {} }:

let
  # Dependencies
  dependencies = with pkgs; [
    rofi
    networkmanager
    gawk
    gnugrep
    libnotify
  ];

  # Create the script
  wifiScript = pkgs.writeShellScriptBin "wifi-manager" ''
    #!/usr/bin/env bash

    # Dependencies: rofi, nmcli, awk, grep

    # Function to connect to a network
    connect_to_network() {
        local ssid="$1"
        
        # Check if connection to this SSID already exists in saved connections
        if nmcli -t -f NAME connection show | grep -Fx "$ssid" &>/dev/null; then
            # Use existing connection (with saved password)
            echo "Using saved profile for '$ssid'"
            nmcli connection up id "$ssid"
            return $?
        fi
        
        # If no saved connection exists, check if the network requires a password
        if nmcli -t -f SSID,SECURITY device wifi list | grep -F "$(echo "$ssid" | sed 's/:/\\:/g'):" | grep -q "WPA"; then
            # Use rofi to request password
            password=$(rofi -dmenu -p "Password for '$ssid'" -password -lines 0)
            
            # If user cancels password input
            if [[ -z "$password" ]]; then
                return 1
            fi
            
            # Connect to network with password and save to NetworkManager profile
            nmcli device wifi connect "$ssid" password "$password"
        else
            # Connect to network without password
            nmcli device wifi connect "$ssid"
        fi
    }

    # Get list of available SSIDs with signal strength and security info
    networks=$(nmcli --colors no --fields SSID,BARS,SECURITY,IN-USE device wifi list | tail -n +2)

    formatted_networks=""
    connected_ssid=""

    # Use IFS to read based on full lines
    while IFS= read -r line; do
        # Extract SSID handling spaces correctly
        in_use=$(echo "$line" | grep -o "^\*" || echo "")
        line_without_star=''${line#\* }
        line_without_star=''${line#  }
        
        ssid=$(echo "$line_without_star" | awk -F ' {2,}' '{print $1}')
        signal=$(echo "$line_without_star" | awk -F ' {2,}' '{print $2}')
        security=$(echo "$line_without_star" | awk -F ' {2,}' '{print $3}')
        
        # Skip networks with empty SSID
        if [[ -z "$ssid" || "$ssid" == "--" ]]; then
            continue
        fi
        
        # Mark only connected networks, don't show saved status
        if [[ -n "$in_use" ]]; then
            formatted_networks+="$ssid ∷ $signal ∷ $security ∷ [Connected]\n"
            connected_ssid="$ssid"
        else
            formatted_networks+="$ssid ∷ $signal ∷ $security\n"
        fi
    done <<< "$networks"

    # Add options to rescan and manage saved connections
    formatted_networks+="[Rescan WiFi Networks]\n"
    formatted_networks+="[Manage Saved Connections]"

    # Display rofi menu
    chosen_network=$(echo -e "$formatted_networks" | rofi -dmenu -i -p "Select WiFi Network" -lines 15 -width 40)

    # If nothing is selected (user cancel)
    if [[ -z "$chosen_network" ]]; then
        exit 0
    fi

    # If rescan option is selected
    if [[ "$chosen_network" == "[Rescan WiFi Networks]" ]]; then
        nmcli device wifi rescan
        # Wait a bit to ensure scan completes
        sleep 2
        # Run script again to refresh
        exec "$0"
        exit 0
    fi

    # If manage connections option is selected
    if [[ "$chosen_network" == "[Manage Saved Connections]" ]]; then
        # Get list of saved WiFi connections
        saved_connections=$(nmcli -t -f NAME,TYPE connection show | grep ':802-11-wireless$' | cut -d':' -f1)
        
        if [[ -z "$saved_connections" ]]; then
            notify-send "WiFi" "No saved connections"
            exit 0
        fi
        
        # Add back option
        saved_connections+=$(echo -e "\n[Back]")
        
        # Display list of saved connections
        selected_conn=$(echo -e "$saved_connections" | rofi -dmenu -i -p "Manage Saved Connections" -lines 10)
        
        if [[ -z "$selected_conn" || "$selected_conn" == "[Back]" ]]; then
            exec "$0"
            exit 0
        fi
        
        # Ask action for saved connection
        action=$(echo -e "Connect\nForget\nBack" | rofi -dmenu -i -p "Action for '$selected_conn'")
        
        case "$action" in
            "Connect")
                nmcli connection up id "$selected_conn"
                if [[ $? -eq 0 ]]; then
                    notify-send "WiFi" "Connected to '$selected_conn'"
                else
                    notify-send "WiFi" "Failed to connect to '$selected_conn'"
                fi
                ;;
            "Forget")
                nmcli connection delete id "$selected_conn"
                notify-send "WiFi" "Removed connection '$selected_conn'"
                ;;
            *)
                exec "$0"
                ;;
        esac
        
        exit 0
    fi

    # Extract SSID from selected line safely
    selected_ssid=$(echo "$chosen_network" | awk -F ' ∷ ' '{print $1}')

    # If already connected to this SSID, ask if want to disconnect
    if [[ "$chosen_network" == *"[Connected]"* ]]; then
        action=$(echo -e "Disconnect\nForget\nBack" | rofi -dmenu -i -p "Already connected to '$selected_ssid'")
        
        case "$action" in
            "Disconnect")
                nmcli connection down id "$selected_ssid" 2>/dev/null || nmcli device disconnect wlan0 2>/dev/null
                notify-send "WiFi" "Disconnected from '$selected_ssid'"
                ;;
            "Forget")
                nmcli connection delete id "$selected_ssid"
                notify-send "WiFi" "Removed connection '$selected_ssid'"
                ;;
        esac
        
        exit 0
    fi

    # Check if connection is already saved (without displaying its status in main menu)
    if nmcli -t -f NAME connection show | grep -Fx "$selected_ssid" &>/dev/null; then
        # If connection is already saved, connect directly
        nmcli connection up id "$selected_ssid"
        
        if [[ $? -eq 0 ]]; then
            notify-send "WiFi" "Connected to '$selected_ssid'"
        else
            # If failed, password may have changed
            action=$(echo -e "Use New Password\nForget\nBack" | rofi -dmenu -i -p "Failed to connect to '$selected_ssid'")
            
            case "$action" in
                "Use New Password")
                    # Delete old connection and create new connection
                    nmcli connection delete id "$selected_ssid" &>/dev/null
                    connect_to_network "$selected_ssid"
                    
                    if [[ $? -eq 0 ]]; then
                        notify-send "WiFi" "Connected to '$selected_ssid' with new password"
                    else
                        notify-send "WiFi" "Failed to connect to '$selected_ssid'"
                    fi
                    ;;
                "Forget")
                    nmcli connection delete id "$selected_ssid"
                    notify-send "WiFi" "Removed connection '$selected_ssid'"
                    ;;
            esac
        fi
    else
        # Connect to unsaved network
        connect_to_network "$selected_ssid"
        
        # Display connection status notification
        if [[ $? -eq 0 ]]; then
            notify-send "WiFi" "Connected to '$selected_ssid'"
        else
            notify-send "WiFi" "Failed to connect to '$selected_ssid'"
        fi
    fi
  '';
in

pkgs.buildEnv {
  name = "wifi-manager-env";
  paths = dependencies ++ [ wifiScript ];
  
  # Add meta information
  meta = {
    description = "A WiFi network manager using rofi and NetworkManager";
    longDescription = ''
      This package provides a GUI tool built with rofi for managing WiFi networks.
      Features:
      - Connect to WiFi networks
      - Manage saved connections
      - Rescan for networks
      - Secure password entry
    '';
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.linux;
  };
}
