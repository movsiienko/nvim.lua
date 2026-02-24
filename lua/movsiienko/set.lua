vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.undofile = true

vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.o.shell = "/bin/sh"
vim.o.showmode = false
vim.o.cursorline = true

vim.diagnostic.config({ virtual_lines = { current_line = true } })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = vim.api.nvim_create_augroup("highligh-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable Treesitter",
  group = vim.api.nvim_create_augroup("enable_treesitter", {}),
  -- Don't filter by `pattern`, install and enable Treesitter parsers for all languages.
  callback = function()
    -- Enable Treesitter syntax highlighting.
    if pcall(vim.treesitter.start) then
      -- Use Treesitter indentation and folds.
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      -- vim.wo.foldmethod = "expr"
      -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})


vim.cmd("colorscheme kanagawa-dragon")
