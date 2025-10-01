if vim.g.neovide then
  vim.o.guifont = "CaskaydiaMono Nerd Font:h15"
  vim.g.neovide_refresh_rate = 166
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
end
