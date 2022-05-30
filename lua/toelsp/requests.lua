local M = {}
local handlers = require('toelsp.handlers')

local function request(method, handler)
  vim.validate({
    method = { method, 'string' },
    handler = { handler, 'function' }
  })

  local params = vim.lsp.util.make_position_params()

  return vim.lsp.buf_request(0, method, params, handler)
end

function M.hover()
  local method = 'textDocument/hover'
  local handler = handlers.doc_handler

  request(method, handler)
end

function M.declaration()
  local method = 'textDocument/declaration'
  local handler = handlers.location_handler

  request(method, handler)
end

function M.definition()
  local method = 'textDocument/definition'
  local handler = handlers.location_handler

  request(method, handler)
end

function M.implementation()
  local method = 'textDocument/implementation'
  local handler = handlers.location_handler

  request(method, handler)
end

function M.typeDefinition()
  local method = 'textDocument/typeDefinition'
  local handler = handlers.location_handler

  request(method, handler)
end

function M.references()
  local def_method = 'textDocument/definition'
  local def_handler = handlers.references_handler_def
  local ref_method = 'textDocument/references'
  local ref_handler = handlers.references_handler_ref

  request(def_method, def_handler)
  request(ref_method, ref_handler)
end

return M
