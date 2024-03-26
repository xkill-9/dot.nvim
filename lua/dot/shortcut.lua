local curl = require('plenary.curl')
local utils = require('dot.utils')

local M = {}

local function get_token()
  return vim.env['SHORTCUT_API_TOKEN']
end

local function get_headers()
  return {
    ['Shortcut-Token'] = get_token(),
    content_type = 'application/json',
  }
end

function M.get_story_branch(opts)
  return opts.mention_name .. '/sc-' .. opts.id .. '/' .. utils.slugify(opts.name)
end

function M.get_current_user()
  local res = curl.get('https://api.app.shortcut.com/api/v3/member', { headers = get_headers() })

  return vim.fn.json_decode(res.body)
end

function M.get_stories()
  -- Lazy load current user
  if not vim.g.dot_viewer then
    vim.g.dot_viewer = M.get_current_user()
  end

  local query = { page_size = 25, query = string.format('owner:%s', vim.g.dot_viewer.mention_name), detail = 'slim' }
  local results = curl.get('https://api.app.shortcut.com/api/v3/search/stories', {
    headers = get_headers(),
    query = query,
  })
  local resp = vim.fn.json_decode(results.body).data

  if not resp then
    return {}
  end

  return resp
end

return M
