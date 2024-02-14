{ ... }:

{
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
            z = "zellij";
            lv = "lvim";

	    cat ="bat";
	    nf = "cd ~/.dotfiles";
	    cw = "swww img ~/.dotfiles/user/wm/Frosted-Glass/";
            cp = "cp -rv";
            ll = "eza -lah";
	    ls = "eza";
            mv = "mv -v";
            rm = "rm -rfv";
            lsf = "lsblk -o name,fstype,fsavail,fsused,size,mountpoint";

            scs = "doas systemctl start";
            sct = "doas systemctl stop";
            scr = "doas systemctl restart";
            scu = "doas systemctl status";

            qup = "quarto publish netlify --no-browser";
            quv = "quarto preview";
            qur = "quarto render";

            neq = "nix-env -qaP";
            nim = "nix-shell -p nix-info --run 'nix-info -m'";
            nei = "doas nix-env -iA";
            neu = "doas nix-env --uninstall";
            nel = "doas nix-env -p /nix/var/nix/profiles/system --list-generations";
            ned = "doas nix-env -p /nix/var/nix/profiles/system --delete-generations old";

            ncl = "doas nix-channel --list";
            ncu = "doas nix-channel --update";
            nrd = "doas nixos-rebuild dry-build";
            nrs = "cd ~/.dotfiles && doas nixos-rebuild switch --flake .#system";
            nru = "cd ~/.dotfiles && doas nixos-rebuild switch --upgrade --flake .#system";
            ngc = "doas nix-store --gc";
            ngd = "doas nix-collect-garbage -d";

            hms = "cd ~/.dotfiles && home-manager switch --flake .#user";
            hmu = "cd ~/.dotfiles && home-manager switch --upgrade --flake .#user";

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

            gfs = "git fetch sh";
            gfg = "git fetch gh";
            gfl = "git fetch gl";
            gfa = "git fetch --all --prune";

            gignore = "git update-index --assume-unchanged";

            gls = "git log --stat";
            glsp = "git log --stat -p";
            glg = "git log --graph";
            glo = "git log --oneline --decorate";

            gm = "git merge";
            gmsm = "git merge sh/main";
            gmgm = "git merge gh/main";
            gmlm = "git merge gl/main";
            gmt = "git mergetool --no-prompt";

            gpsm = "git push -u sh main";
            gpgm = "git push -u gh main";
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
            gusm = "git pull sh main";
            gugm = "git pull gh main";
            gulm = "git pull gl main";
          };
        };
      };

}
