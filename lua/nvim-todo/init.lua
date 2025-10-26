local M = {}

local function center_in(outer, inner)
  return (outer - inner) / 2
end

local function window_config()
  local width = math.min(math.floor(vim.o.columns * 0.8), 64)
  local height = math.floor(vim.o.lines * 0.8)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = center_in(vim.o.columns, width),
    row = center_in(vim.o.lines, height),
  }
end

local function expand_path(path)
  if path:sub(1, 1) == "~" then
    return os.getenv("HOME") .. path:sub(2)
  end
  return path
end

local function mark_done()
  local original_word = vim.fn.expand("<cword>")

  if original_word == '' then
    return
  end
  local new_word = original_word
  if original_word:find('^- [ ]') then
    new_word = original_word:gsub('- [ ]', '- [x]')
    print(new_word)
  elseif original_word:find('- [x]') then
    new_word = original_word:gsub('- [x]', '- [ ]')
    print(new_word)
  end

  local replacement_keys = "ciw" .. new_word .. "<Esc>"

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(replacement_keys, true, true, true),
    "n",
    false
  )
end

local function open_floating_file(target_file)
  local expanded_path = expand_path(target_file)

  if vim.fn.filereadable(expanded_path) == 0 then
    vim.notify("File not exist at: " .. expanded_path, vim.log.levels.ERROR)
  end

  local buf = vim.fn.bufnr(expanded_path, true)
  if buf == -1 then
    buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, expanded_path)
  end

  vim.bo[buf].swapfile = false

  local win = vim.api.nvim_open_win(buf, true, window_config())
end

local function setup_user_commands(opts)
  local target_file = opts.target_file or "todo.md"
  vim.api.nvim_create_user_command("Td", function()
    open_floating_file(target_file)
  end, {})

  vim.api.nvim_create_user_command("Tdm", function()
    mark_done()
  end, {})
end



M.setup = function(opts)
  setup_user_commands(opts)
end

return M
