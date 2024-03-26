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
  local query = { page_size = 25, query = string.format('owner:%s', vim.g.dot_viewer.mention_name), detail = 'slim' }
  local results = M.request({
    url = 'search/stories',
    query = query,
  })
  local resp = vim.fn.json_decode(results.body).data

  if not resp then
    return {}
  end

  return resp
end

function M.request(opts)
  opts = opts or {}
  local spec = {
    headers = get_headers(),
  }
  -- Lazy load current user on the first request
  if not vim.g.dot_viewer then
    vim.g.dot_viewer = M.get_current_user()
  end

  -- default to get request
  opts = vim.tbl_extend('keep', opts, {
    method = 'get',
  })

  if utils.startsWith(opts.url, 'http') then
    spec.url = opts.url
  else
    spec.url = 'https://api.app.shortcut.com/api/v3/' .. opts.url
  end

  opts = vim.tbl_extend('force', opts, spec)

  return curl.request(opts)
end

return M
