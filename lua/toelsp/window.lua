local M = {}

local util = vim.lsp.util
local npcall = vim.F.npcall

local function set_win_opts(winnr, opts)
  for k, v in pairs(opts) do
    vim.api.nvim_win_set_option(winnr, k, v)
  end
end

local function set_buf_vars(bufnr, opts)
  for k, v in pairs(opts) do
    vim.api.nvim_buf_set_var(bufnr, k, v)
  end
end

local function set_window_autoclose(events, winnr, bufnr)
  local augroup = 'toelsp_window_' .. winnr

  vim.api.nvim_create_augroup(augroup, { clear = true })
  vim.api.nvim_create_autocmd(events, {
    group = augroup,
    callback = function() M.close_window(winnr, bufnr) end
  })
end

-- Slightly modified vim.lsp.util.open_floating_preview
local function create_floating_window(contents, opts)
  -- Create a scratch buffer an populate
  local floating_bufnr = vim.api.nvim_create_buf(false, true)

  if opts.do_stylize then
    contents = util.stylize_markdown(floating_bufnr, contents, opts)
  else
    vim.api.nvim_buf_set_lines(floating_bufnr, 0, -1, true, contents)
  end

  -- Create a window for the buffer
  local width, height = util._make_floating_popup_size(contents, opts)

  -- make_floating_popup_options overrides a lot in the third arg, so we merge
  -- it in after the fact
  local winopts = util.make_floating_popup_options(width, height)
  winopts = vim.tbl_deep_extend('force', winopts, opts.winopts)

  local floating_winnr = vim.api.nvim_open_win(floating_bufnr, false, winopts)

  set_buf_vars(floating_bufnr, {
    modifiable = false,
    bufhidden = 'wipe',
    wrap = opts.wrap
  })
  set_win_opts(floating_winnr, {
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
  opts.do_stylize = opts.do_stylize ~= false
  opts.close_events = opts.close_events or { 'CursorMoved', 'CursorMovedI', 'InsertCharPre' }
  opts.winopts = opts.winopts or {}

  local bufnr, winnr = create_floating_window(contents, opts)
  set_window_autoclose(opts.close_events, winnr, bufnr)
end

function M.close_window(winnr, bufnr)
  local augroup = 'toelsp_window_' .. winnr

  -- Erase window, buffer and everything in associated augroup
  npcall(vim.api.nvim_win_close, winnr, true)
  npcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  vim.api.nvim_create_augroup(augroup, { clear = true })
end

return M
