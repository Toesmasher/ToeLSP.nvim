local M = {}

local util = vim.lsp.util

local config = require('toelsp.config')
local notification = require('toelsp.notification')
local window = require('toelsp.window')

-- Handler for methods that may jump to somewhere else:
--  textDocument/declaration
--  textDocument/definition
--  textDocument/implementation
--  textDocument/references
--  textDocument/typeDefinition
function M.location_handler(_, result, ctx, _)
  if result == nil or vim.tbl_isempty(result) then
    if config.options.debug then
      notification.debug('No location found')
    end
    return
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not vim.tbl_islist(result) then
    util.jump_to_location(result, client)
  elseif #result == 1 then
    util.jump_to_location(result[1], client)
  else
    notification.warn('Got %i results', #result)
  end
end

-- Handler for methods that render documentation
--  textDocument/hover
function M.doc_handler(_, result, ctx, cfg)
  if not result then
    return
  end

  local markdown_lines = util.convert_input_to_markdown_lines(result.contents)
  markdown_lines = util.trim_empty_lines(markdown_lines)

  if vim.tbl_isempty(markdown_lines) then
    return
  end

  local opts = {
    do_stylize = result.contents.kind == 'markdown',
    method = ctx.method,
    window_settings = {
      border = 'rounded',
    }
  }

  window.create_popup_docs(markdown_lines, opts)
end

function M.references_handler_def(_, result, ctx, _)
  vim.notify('Def handler')
end

function M.references_handler_ref(_, result, ctx, _)
  vim.notify('Ref handler')
end

return M
