if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font:h17"
  vim.g.neovide_refresh_rate = 144
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
end
