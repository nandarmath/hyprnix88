{ pkgs }:

pkgs.writeShellScriptBin "web-search" ''
  declare -A URLS

  URLS=(
    ["🌎 Search"]="https://search.brave.com/search?q="
    ["❄️  Unstable Packages"]="https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query="
    ["❄️  NixOs Wiki"]="https://https://wiki.nixos.org/w/index.php?search="
    ["🏠 Manager Options"]="https://home-manager-options.extranix.com/?query="
    ["🎞️ YouTube"]="https://www.youtube.com/results?search_query="
    ["ℹ️  Google-Translate"]="https://translate.google.com/?sl=auto&tl=id&text="
    ["📕 KBBI"]="https://kbbi.kemdikbud.go.id/entri/"
    ["🦥 Arch Wiki"]="https://wiki.archlinux.org/title/"
    ["🐃 Gentoo Wiki"]="https://wiki.gentoo.org/index.php?title="
  )

  # List for rofi
  gen_list() {
    for i in "''${!URLS[@]}"
    do
      echo "$i"
    done
  }

  main() {
    # Pass the list to rofi
    platform=$( (gen_list) | ${pkgs.rofi-wayland}/bin/rofi -dmenu )

    if [[ -n "$platform" ]]; then
      query=$( (echo ) | ${pkgs.rofi-wayland}/bin/rofi -dmenu )

      if [[ -n "$query" ]]; then
	url=''${URLS[$platform]}$query
	zen "$url"
      else
	exit
      fi
    else
      exit
    fi
  }

  main

  exit 0
''
