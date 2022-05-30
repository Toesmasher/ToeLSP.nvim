local M = {}

local util = vim.lsp.util
local npcall = vim.F.npcall

local windows = {}

local function set_window_opts(winnr, opts)
  for k, v in pairs(opts) do
    vim.api.nvim_win_set_option(winnr, k, v)
  end
end

local function set_buf_opts(bufnr, opts)
  for k, v in pairs(opts) do
    vim.api.nvim_buf_set_var(bufnr, k, v)
  end
end

local function set_popup_autoclose(events, winnr, bufnr)
  local augroup = 'toelsp_window_' .. winnr

  vim.api.nvim_create_augroup(augroup, { clear = true })
  vim.api.nvim_create_autocmd(events, { 
    group = augroup,
    callback = function() M.close_window(winnr, bufnr) end
  })
end

function M.close_window(winnr, bufnr)
  local augroup = 'toelsp_window_' .. winnr

  -- Erase window, buffer and everything in associated augroup
  npcall(vim.api.nvim_win_close, winnr, true)
  npcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  vim.api.nvim_create_augroup(augroup, { clear = true })
end

-- Slightly modified vim.lsp.util.open_floating_preview
local function create_window(contents, opts)
  local bufnr = vim.api.nvim_get_current_buf()

  -- Create a scratch buffer an populate
  local floating_bufnr = vim.api.nvim_create_buf(false, true)

  if opts.do_stylize then
    contents = util.stylize_markdown(floating_bufnr, contents, opts)
  else
    vim.api.nvim_buf_set_lines(floating_bufnr, 0, -1, true, contents)
  end

  -- Create a window for the buffer
  local width, height = util._make_floating_popup_size(contents, opts)
  local window_opts = util.make_floating_popup_options(width, height, {})

  -- Run over the defaults with user-defined config
  if opts.window_settings then
    window_opts = vim.tbl_deep_extend('force', window_opts, opts.window_settings)
  end

  local floating_winnr = vim.api.nvim_open_win(floating_bufnr, false, window_opts)

  set_buf_opts(floating_bufnr, {
    modifiable = false,
    bufhidden = 'wipe',
    wrap = opts.wrap
  })
  set_window_opts(floating_winnr, {
    conceallevel = 2,
    concealcursor = 'n',
    foldenable = false,
    winhl = 'Normal:'
  })

  return floating_bufnr, floating_winnr
end

-- Create a floating window for documentation content
function M.create_popup_docs(contents, opts)
  vim.validate({
    contents = { contents, 'table' },
    opts = { opts, 'table' },
  })

  opts.wrap_at = opts.wrap_at or vim.api.nvim_win_get_width(0)
  opts.wrap = true
  opts.do_stylize = opts.do_stylize ~= false
  opts.close_events = opts.close_events or { 'CursorMoved', 'CursorMovedI', 'InsertCharPre' }
  opts.window_settings = opts.window_settings or {} 

  local bufnr, winnr = create_window(contents, opts)
  set_popup_autoclose(opts.close_events, winnr, bufnr)
end

return M
