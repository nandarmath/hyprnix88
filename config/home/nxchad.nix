{ pkgs, ... }:
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

    plugins.quarto = {
      enable = true;
      autoLoad = true;
      settings = {
        codeRunner.enabled = true;
        codeRunner.default_method = "molten";
        lspFeatures.completion.enabled = true;
        lspFeatures.chunks = "curly";
        lspFeatures.languages = ["r" "python"];
        lspFeatures.diagnostics.enabled = true;
      };
    };
  };
  programs.nixvim = {
    # change theme nvchad
    nvchad.config.base46.theme = "starlight";
  };

}
