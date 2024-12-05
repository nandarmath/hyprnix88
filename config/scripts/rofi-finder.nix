{ pkgs ? import <nixpkgs> {}, ... }:

pkgs.writeShellScriptBin "rofi-finder" ''
  # Rofi File Finder Script
  if [ ! -z "$@" ]; then
    QUERY="$@"
    
    # Open file or directory directly
    if [[ "$@" == /* ]]; then
      if [[ "$@" == *\?\? ]]; then
        # Open parent directory
        ${pkgs.xfce.exo}/bin/exo-open "''${QUERY%\/* \?\?}" > /dev/null 2>&1
        exit
      else
        # Open selected path
        ${pkgs.xfce.exo}/bin/exo-open "$@" > /dev/null 2>&1
        exit
      fi
    
    # Show help
    elif [[ "$@" == \!\!* ]]; then
      echo "!!-- Type your search query to find files"
      echo "!!-- To search again type !<search_query>"
      echo "!!-- To search parent directories type ?<search_query>"
      echo "!!-- You can print this help by typing !!"
    
    # Search in parent directories
    elif [[ "$@" == \?* ]]; then
      echo "!!-- Type another search query"
      ${pkgs.findutils}/bin/find ~ -type d -path '*/\.*' -prune -o -not -name '.*' -type f -iname *"''${QUERY#\?}"* -print | while read -r line; do
        echo "$line" \?\?
      done
    
    # Normal file search
    else
      echo "!!-- Type another search query"
      ${pkgs.findutils}/bin/find ~ -type d -path '*/\.*' -prune -o -not -name '.*' -type f -iname *"''${QUERY#!}"* -print
    fi
  
  # Default help message
  else
    echo "!!-- Type your search query to find files"
    echo "!!-- To search again type !<search_query>"
    echo "!!-- To search parent directories type ?<search_query>"
    echo "!!-- You can print this help by typing !!"
  fi
''
