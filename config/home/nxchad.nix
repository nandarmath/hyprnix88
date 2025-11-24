{ lib, pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    plugins.cmp-path.enable = true;
    plugins.cmp-path.autoLoad = true;
    keymaps = [
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
      }
    ];
    plugins.markdown-preview = {
      enable = true;
      autoLoad = true;
      settings = {
        auto_close = 0;
        auto_start = 0;
        combine_preview = 1;
        combine_preview_auto_refresh = 1;
        preview_options = {
          katex = null;
          maid = null;
          toc = null;
          sequence_diagrams = null;
          mkit = null;
        };
      };
    };
    plugins.hlchunk = {
      enable = true;
      autoLoad = true;
      settings = {
        chunk = {
          enable = true;
          chars = {
            horizontal_line = "─";
            left_bottom = "╰";
            left_top = "╭";
            right_arrow = "─";
            vertical_line = "│";
          };
          style = "#91bef0";
          line_num = {
            style = "#91bef0";
          };
        };

      };
    };

    plugins.supermaven = {
      enable = true;
      autoLoad = true;
      settings = {
        keymaps = {
          accept_suggestion = "<Tab>";
          clear_suggestions = "<C-]>";
          accept_word = "<C-j>";
        };
        ignore_filetypes = [ "cpp" ];
        color = {
          suggestion_color = "#ffffff";
          cterm = 244;
        };
        log_level = "info";
        disable_inline_completion = false;
        disable_keymaps = false;
      };
    };

    plugins.quarto = {
      enable = true;
      autoLoad = true;
      settings = {
        codeRunner.enabled = true;
        codeRunner.default_method = "vim-slime";
        lspFeatures.completion.enabled = true;
        lspFeatures.chunks = "curly";
        lspFeatures.languages = [
          "r"
          "python"
        ];
        lspFeatures.diagnostics.enabled = true;
      };
    };
  };
  programs.nixvim = {
    # change theme nvchad
    nvchad.config.base46.theme = "starlight";
  };

}
