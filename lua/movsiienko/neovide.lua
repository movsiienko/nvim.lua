if vim.g.neovide then
  vim.o.guifont = "CaskaydiaMono Nerd Font:h15"
  vim.g.neovide_refresh_rate = 166
  vim.keymap.set("n", "<D-v>", '"+P')
  vim.keymap.set("v", "<D-v>", '"+P')
  vim.keymap.set("i", "<D-v>", "<C-r>+")
  vim.keymap.set({ "n", "v" }, "<S-Insert>", '"+P')
  vim.keymap.set("i", "<S-Insert>", "<C-r>+")
end
