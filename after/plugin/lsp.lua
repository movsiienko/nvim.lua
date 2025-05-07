-- NOTE: to make any of this work you need a language server.
-- If you don't know what that is, watch this 5 min video:
-- https://www.youtube.com/watch?v=LaS32vctfOY

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.rq", -- your file pattern
  callback = function()
    vim.bo.filetype = "sparql"
  end,
})
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "ruff", "rust_analyzer", "lua_ls", "biome", "ts_ls" },
})

-- Check if the config is already defined (useful when reloading this file)
vim.lsp.config.sparql_language_server = {
  cmd = { "node", "/opt/homebrew/lib/node_modules/sparql-language-server/dist/cli.js", "--stdio" },
  filetypes = { "sparql" },
}
vim.lsp.enable({ "sparql_language_server" })
-- Reserve a space in the gutter
vim.opt.signcolumn = "yes"

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require("lspconfig").util.default_config
lspconfig_defaults.capabilities =
  vim.tbl_deep_extend("force", lspconfig_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
    vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
    vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
    vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
    vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
    vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
    vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
    vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
    vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
  end,
})

local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
  sources = {
    { name = "nvim_lsp" },
    { name = "copilot" },
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol", -- show only symbol annotations
      ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      show_labelDetails = true, -- show labelDetails in menu. Disabled by default
      symbol_map = { Copilot = "" },
    }),
  },
})
