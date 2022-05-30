local M = {}

local notification = require('toelsp.notification')

local CONFIG_DEFAULTS = {
  debug = false,
  diagnostics = {
  },
}

M.options = {}

function M.setup(opts)
  if opts == nil or type(opts) ~= 'table' then
    notification.warn('No configuration given, use an empty table if defaults are good enough')
    opts = {}
  end

  M.options = vim.tbl_deep_extend('force', CONFIG_DEFAULTS, opts)
end

return M
