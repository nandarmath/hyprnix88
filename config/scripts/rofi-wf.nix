{ pkgs ? import <nixpkgs> {} }:

pkgs.symlinkJoin {
  name = "wifi-manager";
  paths = [
    (pkgs.writeShellScriptBin "connect-to-network" ''
      local ssid="$1"
      
      # Check if connection to this SSID already exists in saved connections
      if ${pkgs.networkmanager}/bin/nmcli -t -f NAME connection show | grep -Fx "$ssid" &>/dev/null; then
          # Use existing connection (with saved password)
          echo "Using saved profile for '$ssid'"
          ${pkgs.networkmanager}/bin/nmcli connection up id "$ssid"
          return $?
      fi
      
      # If no saved connection, check if network requires password
      if ${pkgs.networkmanager}/bin/nmcli -t -f SSID,SECURITY device wifi list | grep -F "$(echo "$ssid" | sed 's/:/\\:/g'):" | grep -q "WPA"; then
          # Use rofi to request password
          password=$(${pkgs.rofi}/bin/rofi -dmenu -p "Password for '$ssid'" -password -lines 0)
          
          # If user cancels password input
          if [[ -z "$password" ]]; then
              return 1
          fi
          
          # Connect to network with password and save to NetworkManager profile
          ${pkgs.networkmanager}/bin/nmcli device wifi connect "$ssid" password "$password"
      else
          # Connect to network without password
          ${pkgs.networkmanager}/bin/nmcli device wifi connect "$ssid"
      fi
    '')

    (pkgs.writeShellScriptBin "wifi-menu" ''
      # Function to connect to a network
      connect_to_network() {
        local ssid="$1"
        
        # Check if connection to this SSID already exists in saved connections
        if ${pkgs.networkmanager}/bin/nmcli -t -f NAME connection show | grep -Fx "$ssid" &>/dev/null; then
            # Use existing connection (with saved password)
            echo "Using saved profile for '$ssid'"
            ${pkgs.networkmanager}/bin/nmcli connection up id "$ssid"
            return $?
        fi
        
        # If no saved connection, check if network requires password
        if ${pkgs.networkmanager}/bin/nmcli -t -f SSID,SECURITY device wifi list | grep -F "$(echo "$ssid" | sed 's/:/\\:/g'):" | grep -q "WPA"; then
            # Use rofi to request password
            password=$(${pkgs.rofi}/bin/rofi -dmenu -p "Password for '$ssid'" -password -lines 0)
            
            # If user cancels password input
            if [[ -z "$password" ]]; then
                return 1
            fi
            
            # Connect to network with password and save to NetworkManager profile
            ${pkgs.networkmanager}/bin/nmcli device wifi connect "$ssid" password "$password"
        else
            # Connect to network without password
            ${pkgs.networkmanager}/bin/nmcli device wifi connect "$ssid"
        fi
      }
      
      show_wifi_menu() {
          # Get currently active SSID
          active_device=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE device status | grep ':wifi$' | cut -d':' -f1 | head -n1)
          active_connection=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,CONNECTION device status | grep "^''${active_device}:" | cut -d':' -f2)

          echo "Active device: $active_device"
          echo "Active connection: $active_connection"

          # Get list of available SSIDs with signal strength and security info
          networks=$(${pkgs.networkmanager}/bin/nmcli --colors no --fields SSID,BARS,SECURITY,IN-USE device wifi list | tail -n +2)

          formatted_networks=""

          # Use IFS to read based on full lines
          while IFS= read -r line; do
              # Extract SSID handling spaces correctly
              in_use=$(echo "$line" | grep -o "^\*" || echo "")
              line_without_star=''${line#\* }
              line_without_star=''${line#  }
              
              ssid=$(echo "$line_without_star" | ${pkgs.gawk}/bin/awk -F ' {2,}' '{print $1}')
              signal=$(echo "$line_without_star" | ${pkgs.gawk}/bin/awk -F ' {2,}' '{print $2}')
              security=$(echo "$line_without_star" | ${pkgs.gawk}/bin/awk -F ' {2,}' '{print $3}')
              
              # Skip networks with empty SSID
              if [[ -z "$ssid" || "$ssid" == "--" ]]; then
                  continue
              fi
              
              # Mark connected network with "Connected" label
              if [[ -n "$in_use" || "$ssid" == "$active_connection" ]]; then
                  formatted_networks+="$ssid [Connected] ∷ $signal ∷ $security\n"
              else
                  formatted_networks+="$ssid ∷ $signal ∷ $security\n"
              fi
          done <<< "$networks"

          # Add options to rescan and manage saved connections
          formatted_networks+="[Rescan WiFi Networks]\n"
          formatted_networks+="[Manage Saved Connections]"

          # Display rofi menu
          chosen_network=$(echo -e "$formatted_networks" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Select WiFi Network" -lines 15 -width 40)

          # If nothing selected (user cancel)
          if [[ -z "$chosen_network" ]]; then
              exit 0
          fi

          # If rescan option selected
          if [[ "$chosen_network" == "[Rescan WiFi Networks]" ]]; then
              echo "Rescanning WiFi networks..."
              ${pkgs.libnotify}/bin/notify-send "WiFi" "Scanning WiFi networks..."
              
              # Ensure all WiFi devices are scanned
              for wifi_dev in $(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE device status | grep ':wifi$' | cut -d':' -f1); do
                  ${pkgs.networkmanager}/bin/nmcli device wifi rescan ifname "$wifi_dev" &>/dev/null
              done
              
              # If no specific device, do general scan
              if [ $? -ne 0 ]; then
                  ${pkgs.networkmanager}/bin/nmcli device wifi rescan &>/dev/null
              fi
              
              # Wait a bit to ensure scan completes
              sleep 2
              ${pkgs.libnotify}/bin/notify-send "WiFi" "Network scan complete"
              
              # Call function again to refresh
              show_wifi_menu
              return
          fi

          # If manage connections option selected
          if [[ "$chosen_network" == "[Manage Saved Connections]" ]]; then
              # Get list of saved WiFi connections
              saved_connections=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME,TYPE connection show | grep ':802-11-wireless$' | cut -d':' -f1)
              
              if [[ -z "$saved_connections" ]]; then
                  ${pkgs.libnotify}/bin/notify-send "WiFi" "No saved connections"
                  show_wifi_menu
                  return
              fi
              
              # Add back option
              saved_connections+=$(echo -e "\n[Back]")
              
              # Display saved connections list
              selected_conn=$(echo -e "$saved_connections" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Manage Saved Connections" -lines 10)
              
              if [[ -z "$selected_conn" || "$selected_conn" == "[Back]" ]]; then
                  show_wifi_menu
                  return
              fi
              
              # Ask for action on saved connection
              action=$(echo -e "Connect\nForget\nBack" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Action for '$selected_conn'")
              
              case "$action" in
                  "Connect")
                      ${pkgs.networkmanager}/bin/nmcli connection up id "$selected_conn"
                      if [[ $? -eq 0 ]]; then
                          ${pkgs.libnotify}/bin/notify-send "WiFi" "Connected to '$selected_conn'"
                      else
                          ${pkgs.libnotify}/bin/notify-send "WiFi" "Failed to connect to '$selected_conn'"
                      fi
                      ;;
                  "Forget")
                      ${pkgs.networkmanager}/bin/nmcli connection delete id "$selected_conn"
                      ${pkgs.libnotify}/bin/notify-send "WiFi" "Deleted connection '$selected_conn'"
                      ;;
                  *)
                      show_wifi_menu
                      return
                      ;;
              esac
              
              show_wifi_menu
              return
          fi

          # Check if selected network is currently connected
          if [[ "$chosen_network" == *"[Connected]"* ]]; then
              # Extract SSID from connected network
              selected_ssid=$(echo "$chosen_network" | ${pkgs.gawk}/bin/awk -F ' \[Connected\]' '{print $1}')
              
              # Confirm before disconnecting
              action=$(echo -e "Disconnect\nCancel" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Do you want to disconnect from '$selected_ssid'?")
              
              if [[ "$action" == "Disconnect" ]]; then
                  # Try several methods to ensure connection is disconnected
                  # Method 1: Use connection name
                  ${pkgs.networkmanager}/bin/nmcli connection down id "$selected_ssid" 2>/dev/null
                  
                  # Method 2: Use wifi device name
                  if [[ -n "$active_device" ]]; then
                      ${pkgs.networkmanager}/bin/nmcli device disconnect "$active_device" 2>/dev/null
                  fi
                  
                  # Method 3: Try with all known wifi interfaces
                  for dev in $(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE device status | grep ':wifi$' | cut -d':' -f1); do
                      ${pkgs.networkmanager}/bin/nmcli device disconnect "$dev" 2>/dev/null
                  done
                  
                  ${pkgs.libnotify}/bin/notify-send "WiFi" "Disconnected from '$selected_ssid'"
                  sleep 1
                  
                  # Refresh to show latest status
                  show_wifi_menu
                  return
              fi
              
              show_wifi_menu
              return
          else
              # For networks not connected, extract SSID
              selected_ssid=$(echo "$chosen_network" | ${pkgs.gawk}/bin/awk -F ' ∷ ' '{print $1}')
          fi

          # Check if connection is already saved
          if ${pkgs.networkmanager}/bin/nmcli -t -f NAME connection show | grep -Fx "$selected_ssid" &>/dev/null; then
              # If connection already saved, connect directly
              ${pkgs.networkmanager}/bin/nmcli connection up id "$selected_ssid"
              
              if [[ $? -eq 0 ]]; then
                  ${pkgs.libnotify}/bin/notify-send "WiFi" "Connected to '$selected_ssid'"
              else
                  # If failed, password might have changed
                  action=$(echo -e "Use New Password\nForget\nBack" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Failed to connect to '$selected_ssid'")
                  
                  case "$action" in
                      "Use New Password")
                          # Delete old connection and create new one
                          ${pkgs.networkmanager}/bin/nmcli connection delete id "$selected_ssid" &>/dev/null
                          connect_to_network "$selected_ssid"
                          
                          if [[ $? -eq 0 ]]; then
                              ${pkgs.libnotify}/bin/notify-send "WiFi" "Connected to '$selected_ssid' with new password"
                          else
                              ${pkgs.libnotify}/bin/notify-send "WiFi" "Failed to connect to '$selected_ssid'"
                          fi
                          ;;
                      "Forget")
                          ${pkgs.networkmanager}/bin/nmcli connection delete id "$selected_ssid"
                          ${pkgs.libnotify}/bin/notify-send "WiFi" "Deleted connection '$selected_ssid'"
                          ;;
                      *)
                          show_wifi_menu
                          return
                          ;;
                  esac
              fi
          else
              # Connect to unsaved network
              connect_to_network "$selected_ssid"
              
              # Display connection status notification
              if [[ $? -eq 0 ]]; then
                  ${pkgs.libnotify}/bin/notify-send "WiFi" "Connected to '$selected_ssid'"
              else
                  ${pkgs.libnotify}/bin/notify-send "WiFi" "Failed to connect to '$selected_ssid'"
              fi
          fi
          
          # Return to main menu after action
          sleep 1
          show_wifi_menu
      }

      # Start program
      show_wifi_menu
    '')
  ];

  meta = with pkgs.lib; {
    description = "A NetworkManager-based WiFi menu using rofi";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [];
  };
}

