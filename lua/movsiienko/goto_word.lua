-- Word Jump Plugin for Neovim
-- Provides quick navigation by labeling visible words

local M = {}

-- Namespace for virtual text
local ns = vim.api.nvim_create_namespace("word_jump")

-- State management
local state = {
  active = false,
  labels = {},
  extmark_ids = {},
}

-- Generate labels (aa, ab, ac, ..., ba, bb, ...)
local function generate_labels(count)
  local labels = {}
  local chars = "abcdefghijklmnopqrstuvwxyz"
  local label_length = 2

  -- Calculate how many labels we can generate with current length
  local max_labels = math.pow(#chars, label_length)
  if count > max_labels then
    label_length = math.ceil(math.log(count) / math.log(#chars))
  end

  for i = 1, count do
    local label = ""
    local n = i - 1
    for j = 1, label_length do
      label = chars:sub((n % #chars) + 1, (n % #chars) + 1) .. label
      n = math.floor(n / #chars)
    end
    labels[i] = label
  end

  return labels
end

-- Find all words in visible lines
local function find_words()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  -- Get visible line range
  local win_info = vim.fn.getwininfo(win)[1]
  local topline = win_info.topline
  local botline = win_info.botline

  -- Get lines
  local lines = vim.api.nvim_buf_get_lines(buf, topline - 1, botline, false)

  local words = {}

  -- Pattern to match words (including various separators)
  -- This pattern considers parentheses, brackets, and other punctuation as word boundaries
  local word_pattern = "[%w_]+"

  for line_idx, line in ipairs(lines) do
    local line_num = topline + line_idx - 1
    local col = 1

    while col <= #line do
      -- Find next word
      local start_col, end_col = line:find(word_pattern, col)

      if start_col then
        table.insert(words, {
          line = line_num,
          col = start_col,
          text = line:sub(start_col, end_col),
          length = end_col - start_col + 1,
        })
        col = end_col + 1
      else
        -- Look for next non-separator character
        local next_word = line:find("[%w_]", col)
        if next_word then
          col = next_word
        else
          break
        end
      end
    end
  end

  return words
end

-- Display labels as virtual text
local function display_labels(words, labels)
  local buf = vim.api.nvim_get_current_buf()

  state.extmark_ids = {}

  for i, word in ipairs(words) do
    local label = labels[i]
    if label then
      -- Create virtual text that overlays the beginning of the word
      local virt_text = {}
      for j = 1, #label do
        table.insert(virt_text, { label:sub(j, j), "IncSearch" })
      end

      -- Set extmark with overlay virtual text
      local extmark_id = vim.api.nvim_buf_set_extmark(buf, ns, word.line - 1, word.col - 1, {
        virt_text = virt_text,
        virt_text_pos = "overlay",
        priority = 1000,
        hl_mode = "combine",
      })

      table.insert(state.extmark_ids, extmark_id)

      -- Store label info for jumping
      state.labels[label] = {
        line = word.line,
        col = word.col,
      }
    end
  end
end

-- Remove all virtual text
function M.remove_labels()
  if not state.active then
    return
  end

  local buf = vim.api.nvim_get_current_buf()

  -- Clear all extmarks
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  -- Reset state
  state.active = false
  state.labels = {}
  state.extmark_ids = {}

  -- Restore normal mode
  vim.cmd("redraw")
end

-- Get user input for label
local function get_label_input(max_length)
  local input = ""

  -- Temporarily override mappings to capture input
  vim.cmd("redraw")

  while #input < max_length do
    local char = vim.fn.getchar()

    -- Handle special keys
    if char == 27 then -- ESC
      return nil
    elseif char == 13 then -- Enter
      break
    elseif type(char) == "number" and char >= 32 and char <= 126 then
      -- Regular character
      local c = vim.fn.nr2char(char)
      input = input .. c

      -- Check if we have a valid label
      if state.labels[input] then
        return input
      end

      -- Check if this could be a prefix of any label
      local has_prefix = false
      for label, _ in pairs(state.labels) do
        if vim.startswith(label, input) then
          has_prefix = true
          break
        end
      end

      if not has_prefix then
        return nil
      end

      -- Show partial input
      vim.cmd("redraw")
      vim.api.nvim_echo({ { "Jump to: " .. input, "Question" } }, false, {})
    else
      -- Invalid input
      return nil
    end
  end

  return input
end

-- Main function to activate word jump
function M.jump()
  if state.active then
    M.remove_labels()
    return
  end

  -- Find all visible words
  local words = find_words()

  if #words == 0 then
    vim.api.nvim_echo({ { "No words found", "WarningMsg" } }, false, {})
    return
  end

  -- Generate labels
  local labels = generate_labels(#words)

  -- Reset state
  state.active = true
  state.labels = {}

  -- Display labels
  display_labels(words, labels)

  -- Redraw to show labels
  vim.cmd("redraw")

  -- Get user input
  local max_label_length = #labels[#labels] -- Length of the last label
  local selected_label = get_label_input(max_label_length)

  -- Jump to selected word or cleanup
  if selected_label and state.labels[selected_label] then
    local target = state.labels[selected_label]
    vim.api.nvim_win_set_cursor(0, { target.line, target.col - 1 })
  end

  -- Always cleanup
  M.remove_labels()
end

-- Setup function (optional, for configuration)
function M.setup(opts)
  opts = opts or {}

  -- Could add configuration options here
  -- For example: custom highlight group, custom characters for labels, etc.
end

-- Convenience function to create mapping
function M.create_mapping(mode, lhs)
  vim.keymap.set(mode or "n", lhs, M.jump, {
    desc = "Jump to word",
    silent = true,
  })
end

M.create_mapping("n", "<leader>j")

return M
