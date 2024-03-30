local curl = require('plenary.curl')
local utils = require('dot.utils')
local vim = vim

local M = {}

local headers = {
  ['Shortcut-Token'] = vim.env['SHORTCUT_API_TOKEN'],
  content_type = 'application/json',
}

---Returns the currently authenticated member
---@return Member|nil
function M.get_current_member()
  local res = curl.get('https://api.app.shortcut.com/api/v3/member', { headers = headers })

  if res.status ~= 200 then
    utils.error('Unable to authenticate')
    return
  end

  return vim.fn.json_decode(res.body)
end

---Returns the search params for the current member's unfinished Stories.
---@param viewer Member
---@return table
local function get_current_member_stories_search_params(viewer)
  return {
    page_size = 25,
    query = string.format('owner:%s !is:done !is:archived', viewer.mention_name),
    detail = 'slim',
  }
end

---Returns the list of stories currently owned by the user.
---@return Story[]
function M.get_stories()
  local results = M.search({
    entity_type = 'stories',
    query = get_current_member_stories_search_params,
  })
  local resp = vim.fn.json_decode(results.body).data

  if not resp then
    return {}
  end

  return resp
end

function M.search(opts)
  opts = opts or {}
  local spec = {
    url = 'search',
  }

  -- Lazy load current user on the first request
  if not vim.g.dot_viewer then
    vim.g.dot_viewer = M.get_current_member()
  end

  if opts.entity_type then
    spec.url = spec.url .. '/' .. opts.entity_type
  end

  if opts.query ~= nil and type(opts.query) == 'function' then
    spec.query = opts.query(vim.g.dot_viewer)
  else
    spec.query = opts.query
  end

  opts = vim.tbl_extend('force', opts, spec)

  return M.request(opts)
end

--- Get a valid story branch name for git
---@param id string
---@param name string
---@return string
function M.get_story_branch(id, name)
  local slugified_name = utils.slugify(name)
  -- limit to 40 characters
  slugified_name = string.sub(slugified_name, 1, 40)

  return vim.g.dot_viewer.mention_name .. '/sc-' .. id .. '/' .. slugified_name
end

function M.request(opts)
  opts = opts or {}
  local spec = {
    headers = headers,
  }

  -- default to get request
  opts = vim.tbl_extend('keep', opts, {
    method = 'get',
  })

  if vim.startswith(opts.url, 'http') then
    spec.url = opts.url
  else
    spec.url = 'https://api.app.shortcut.com/api/v3/' .. opts.url
  end

  opts = vim.tbl_extend('force', opts, spec)

  return curl.request(opts)
end

return M
