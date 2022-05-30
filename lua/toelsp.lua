local M = {}

local config = require('toelsp.config')
local requests = require('toelsp.requests')

function M.setup(opts)
  config.setup(opts)
end

-- Map all requests 'down' to here for easy access
M.requests = {}
for k, v in pairs(requests) do
  M.requests[k] = v
end

return M
