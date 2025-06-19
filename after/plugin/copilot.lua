-- vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
--     expr = true,
--     replace_keycodes = false
-- })
-- vim.g.copilot_no_tab_map = true

require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = false,
    debounce = 75,
    keymap = {
      accept = "<C-J>",
      auto_trigger = true,
      accept_word = false,
      accept_line = false,
      next = "<C-Right>",
      prev = "<C-Left>",
      dismiss = "<C-K>",
    },
    filetypes = {
      yaml = true,
      json = true,
      markdown = true,
      sh = function()
        if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
          -- disable for .env files
          return false
        elseif vim.fs.basename(vim.api.nvim_buf_get_name(0)) == ".zshrc" then
          return false
        end
        return true
      end,
    },
  },
})
