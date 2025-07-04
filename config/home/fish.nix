{lib, ...}: let
  inherit (import ../../options.nix) flakeDir theShell;
in
  lib.mkIf (theShell == "fish") {
    programs = {
      fish = {
        enable = true;
        shellAbbrs = {
          b = "bat";
          d = "doas";
          g = "git";
          h = "hx";
          j = "joshuto";
          n = "nvim";
          #z = "zellij";
          cat = "bat";
          nf = "cd ~/hyprnix";
          cp = "cp -rv";
          ll = "eza -lah";
          ls = "eza";
          mv = "mv -v";
          rm = "rm -rfv";
          lsf = "lsblk -o name,fstype,fsavail,fsused,size,mountpoint";
          ns = "nix-search";
          yt = "yt-dlp";
          f = "fzf";
          scs = "sudo systemctl start";
          sct = "sudo systemctl stop";
          scr = "sudo systemctl restart";
          scu = "sudo systemctl status";
          wgs = "sudo systemctl stop wg-quick-wg0";
          wgr = "sudo systemctl start wg-quick-wg0";
          qup = "quarto publish netlify --no-browser";
          quv = "quarto preview";
          qur = "quarto render";

          neq = "nix-env -qaP";
          nim = "nix-shell -p nix-info --run 'nix-info -m'";
          nei = "sudo nix-env -iA";
          neu = "sudo nix-env --uninstall";
          nel = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
          ned = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old";

          ncl = "sudo nix-channel --list";
          ncu = "sudo nix-channel --update";
          nrd = "sudo nixos-rebuild dry-build";
          ngc = "sudo nix-store --gc";
          ngd = "sudo nix-collect-garbage -d";

          ga = "git add";
          gaa = "git add --all";

          gb = "git branch";
          gbl = "git blame -b -w";
          gbr = "git branch --remote";

          gcm = "git commit -m";
          gcam = "git commit S --amend";

          gcb = "git checkout -b";
          gck = "git checkout main";

          gcf = "git config --list";
          gcl = "git clone --recursive";
          gcln = "git clean -fd";
          gcp = "git cherry-pick";

          gd = "git diff";
          gdca = "git diff --cached";

          gfs = "git fetch gs";
          gfn = "git fetch gn";
          gfl = "git fetch gl";
          gfa = "git fetch --all --prune";

          gignore = "git update-index --assume-unchanged";

          gls = "git log --stat";
          glsp = "git log --stat -p";
          glg = "git log --graph";
          glo = "git log --oneline --decorate";

          gm = "git merge";
          gmsm = "git merge gs/main";
          gmnm = "git merge gn/main";
          gmlm = "git merge gl/main";
          gmt = "git mergetool --no-prompt";

          gpsm = "git push -u gs main";
          gpnm = "git push -u gn main";
          gplm = "git push -u gl main";

          gr = "git remote";
          gra = "git remote add";
          grh = "git reset HEAD";
          grhh = "git reset HEAD --hard";

          gs = "git status -sbu";
          gsps = "git show --pretty=short --show-signature";
          gsts = "git stash show --text";
          gsu = "git submodule update";

          gts = "git tag -s";
          gta = "git tag -a";

          gur = "git pull --rebase";
          gusm = "git pull gs main";
          gunm = "git pull gn main";
          gulm = "git pull gl main";
        };
        shellAliases = {
          sv = "sudo vim";
          flake-rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}";
          flake-update = "sudo nix flake update ${flakeDir}";
          fr = "nh os switch --hostname $hostname";
          fu = "nh os switch --hostname $hostname --update";
          gcCleanup = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
          jop = "joplin --profile ~/.config/joplin-desktop";
          # ydlmp4='yt-dlp -f "bestvideo&#91;ext=mp4]+bestaudio&#91;ext=m4a]/best&#91;ext=mp4]/best"';
          # ydlmkv="yt-dlp -f "bestvideo&#91;ext=mkv]+bestaudio&#91;ext=mka]/best&#91;ext=mkv]/best"";
          #v="nvim";
          #ls="lsd";
          #ll="lsd -l";
          #la="lsd -a";
          #lal="lsd -al";
          #".."="cd ..";
        };
        shellInit = ''
          set fish_greeting ""
          if test "$TERM_PROGRAM" = "kitty"; or test -n "$KITTY_WINDOW_ID"; or test -n "$KITTY_PID"
            fastfetch
          else if test "$TERM_PROGRAM" = "alacritty"; or string match -q "*alacritty*" $TERM
            pfetch
          end
          export STARSHIP_LOG="error"
          eval "$(starship init fish)"

        '';
      };
    };
  }
