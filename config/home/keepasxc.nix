{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    keepassxc
  ];
  programs = {
    keepassxc = {
      enable = true;
      settings = {
        Browser = {
          Enabled = true;
        };
        GUI = {
          AdvancedSettings = true;
          ApplicationTheme = "classic";
          CheckForUpdates = false;
          ColorPasswords = true;
          CompactMode = true;
          HidePasswords = true;
          MinimizeOnClose = true;
          MinimizeOnStartup = true;
          MinimizeToTray = true;
          MonospaceNotes = true;
          ShowTrayIcon = true;
          TrayIconAppearance = "monochrome-light";
        };
        General = {
          ConfigVersion = 2;
          MinimizeAfterUnlock = true;
        };
        KeeShare = {
          QuietSuccess = true;
        };
        SSHAgent = {
          Enabled = true;
        };
      };
    };
  };
}
