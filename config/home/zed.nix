{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.zed-editor = {
    enable = true;
    userSettings = {
      features = {
        inline_prediction_provider = "zed";
        inline_completion_provider = "zed";
        copilot = false;
      };
      telemetry = {
        metrics = false;
      };
      lsp = {
        rust_analyzer = {
          binary = {path_lookup = true;};
        };
      };
      languages = {
        Nix = {
          language_servers = ["nixd"];
          formatter = {
            external = {
              command = "alejandra";
              arguments = ["-q" "-"];
            };
          };
        };
        Python = {
          language_servers = ["pyright"];
          formatter = {
            external = {
              command = "black";
              arguments = ["-"];
            };
          };
        };
      };
      assistant = {
        version = "2";
        default_model = {
          provider = "zed.dev";
          model = "claude-3-5-sonnet-latest";
        };
      };
      language_models = {
        anthropic = {
          version = "1";
          api_url = "https://api.anthropic.com";
        };
        openai = {
          version = "1";
          api_url = "https://api.openai.com/v1";
        };
        ollama = {
          api_url = "http://localhost:11434";
        };
      };
      ssh_connections = [
        # {
        #   host = "152.53.85.162";
        #   nickname = "m3-atlas";
        #   args = ["-i" "~/.ssh/m3tam3re"];
        # }
      ];
      auto_update = false;
      format_on_save = "on";
      vim_mode = true;
      load_direnv = "shell_hook";
      theme = "Dracula";
      buffer_font_family = lib.mkForce "FiraCode Nerd Font";
      ui_font_size = 16;
      buffer_font_size = 16;
      show_edit_predictions = true;
    };
  };
}
