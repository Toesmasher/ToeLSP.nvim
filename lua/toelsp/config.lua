local M = {}

local notification = require('toelsp.notification')

M.options = {
  debug = false,

  -- Default opts passed to any nvim_open_win
  default_winopts = {
    border = 'rounded',
  },

  diagnostics = {
  },

  hover_doc = {
    position = 'right', -- { 'cursors', 'topright', 'right' }
  }
}

function M.setup(opts)
  if opts == nil or type(opts) ~= 'table' then
    notification.warn('No configuration given, use an empty table if defaults are good enough')
    return
  end
  M.options = vim.tbl_deep_extend('force', M.options, opts)
end

return M
