local lspconfig = require("lspconfig")

require 'lspconfig'.pyright.setup {}
require 'lspconfig'.nil_ls.setup {}
require 'lspconfig'.marksman.setup {}
require 'lspconfig'.rust_analyzer.setup {}
require 'lspconfig'.yamlls.setup {}
require 'lspconfig'.bashls.setup {}
require 'lspconfig'.typst_lsp.setup {
  settings = {
    exportPdf = "onType" -- Choose onType, onSave or never.
    -- serverPath = "" -- Normally, there is no need to uncomment it.
  }
}
