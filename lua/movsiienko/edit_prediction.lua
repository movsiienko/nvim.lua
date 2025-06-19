local M = {}

local buff_cache = {}

vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("EditPrediction", { clear = true }),
  pattern = "*",
  callback = function(args)
    local current_buffer = args.buf
    local prev_lines = buff_cache[current_buffer]
    local curr_lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
    buff_cache[current_buffer] = curr_lines
    if prev_lines == nil then
      return
    end
    local line, column = unpack(vim.api.nvim_win_get_cursor(0))
    local start_index
    if line > 3 then
      start_index = line - 3
    else
      start_index = 1
    end

    local old_lines = {}
    table.move(prev_lines, start_index, line + 3, 1, old_lines)
    table.insert(old_lines, "")

    local new_lines = {}
    table.move(curr_lines, start_index, line + 3, 1, new_lines)
    table.insert(new_lines, "")

    -- print(vim.inspect({ old_lines = old_lines, new_lines = new_lines }))
    local diff = vim.diff(table.concat(old_lines, "\n"), table.concat(new_lines, "\n"))
    -- print(vim.inspect("The diff" .. diff))
  end,
})

function foo()
  local a = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  return "bar"
end

local M = {}
M.diff_extmark_ns = nil -- Namespace for our extmarks

-- Function to show diff using virtual text
-- Compares the current line at cursor with 'hardcoded_string'
function M.show_inline_string_diff(hardcoded_string)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_row_1idx, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local cursor_row_0idx = cursor_row_1idx - 1 -- Convert to 0-indexed for API

  local current_line_content = vim.api.nvim_buf_get_lines(bufnr, cursor_row_0idx, cursor_row_0idx + 1, false)[1]

  local lines1 = { hardcoded_string }
  local lines2 = { current_line_content }

  local diff_result = vim.diff(table.concat(lines1, "\n"), table.concat(lines2, "\n"))

  -- Create or get a unique highlight namespace for our extmarks
  if not M.diff_extmark_ns then
    M.diff_extmark_ns = vim.api.nvim_create_namespace("InlineStringDiff")
  end
  -- Clear any previous extmarks on this specific line from our namespace
  vim.api.nvim_buf_clear_namespace(bufnr, M.diff_extmark_ns, cursor_row_0idx, cursor_row_0idx + 1)

  if #diff_result > 0 then
    local extmark_id_counter = 1 -- Use a simple counter for unique extmark IDs on the line

    -- First, add virtual text for the 'deleted' (hardcoded) part, if different
    -- We place this *above* the current line content
    vim.api.nvim_buf_set_extmark(bufnr, M.diff_extmark_ns, cursor_row_0idx, 6, {
      id = extmark_id_counter, -- Give a unique ID for this extmark
      virt_text = { { "- " .. hardcoded_string, "DiffAdd" } },
      -- virt_lines_leftcol = true,
      -- virt_lines_above = true,
      virt_text_pos = "overlay", -- Display virtual text above the line
      priority = 100, -- Ensure it's visible over other potential extmarks
    })
    extmark_id_counter = extmark_id_counter + 1

    -- Then, highlight the current line as 'DiffChange'
    -- Or, if you want a `+` prefix for the actual line, you could add virtual text 'above' again,
    -- but usually, the line itself gets highlighted and the 'old' version is virtual.
    vim.api.nvim_buf_set_extmark(bufnr, M.diff_extmark_ns, cursor_row_0idx, 0, {
      id = extmark_id_counter,
      end_col = 10,
      hl_group = "DiffDelete",
      -- virt_text = {{'+ ' .. current_line_content, 'DiffAdd'}}, -- Optional: Add '+' prefix as virtual text for current line too
      virt_text_pos = "overlay",
      priority = 150, -- Lower priority than the "old" text's virtual text
    })
    extmark_id_counter = extmark_id_counter + 1

    print(
      string.format(
        "Diff shown for line %d. Original: '%s', Current: '%s'.",
        cursor_row_1idx,
        hardcoded_string,
        current_line_content
      )
    )
  else
    print(string.format("Line %d matches '%s'. No diff.", cursor_row_1idx, hardcoded_string))
  end
end

-- Function to clear the virtual text and highlights
function M.clear_inline_string_diff()
  local bufnr = vim.api.nvim_get_current_buf()
  if M.diff_extmark_ns then
    vim.api.nvim_buf_clear_namespace(bufnr, M.diff_extmark_ns, 0, -1) -- Clear all from this namespace
    print("Inline string diff cleared.")
  else
    print("No active inline string diff to clear.")
  end
end

-- Create user commands for easy testing
vim.api.nvim_create_user_command("DiffLineWithFooVT", function()
  M.show_inline_string_diff("foo") -- Compare current line with "foo"
end, {})

vim.api.nvim_create_user_command("ClearInlineDiffVT", M.clear_inline_string_diff, {})
