local M = {}

function M.debug(msg, ...)
  vim.notify(msg:format(...), vim.log.levels.INFO, { title = 'ToeLSP Debug' })
end

function M.warn(msg, ...)
  vim.notify(msg:format(...), vim.log.levels.WARN, { title = 'ToeLSP' })
end

function M.error(msg, ...)
  vim.notify(msg:format(...), vim.log.levels.ERROR, { title = 'ToeLSP' })
end

return M
