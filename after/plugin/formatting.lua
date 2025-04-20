local conform = require("conform")

conform.setup({
  formatters = {
    sparql_formatter = {
      command = "sparql-formatter",
      args = { "$FILENAME" },
      stdin = true,
    },
  },
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    svelte = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    graphql = { "prettier" },
    lua = { "stylua" },
    python = { "isort", "ruff" },
    sparql = { "sparql_formatter" },
  },
})
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  conform.format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  })
end, { desc = "Format file or range (in visual mode)" })

conform.formatters.ruff = {
  args = { "format", "--stdin-filename", "$FILENAME", "--line-length", "120" },
}

-- conform.formatters.isort = {
--   args = { "--profile", "black" },
-- }

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
