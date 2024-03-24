local curl = require('plenary.curl')
local _, Job = pcall(require, 'plenary.job')

local sc_token = vim.env['SHORTCUT_API_TOKEN']

local headers = {
  ['Shortcut-Token'] = sc_token,
  content_type = 'application/json',
}

local M = {}

function M.log(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = 'Dot.nvim' })
end

local function slugify(name)
  local s = ''
  for word in string.gmatch(name, '%a+') do
    s = s .. string.lower(word) .. '-'
  end

  -- remove trailing '-'
  s = string.sub(s, 1, -2)

  -- limit to 40 characters
  return string.sub(s, 1, 40)
end

function M.get_story_branch(opts)
  return opts.mention_name .. '/sc-' .. opts.id .. '/' .. slugify(opts.name)
end

function M.git_create_branch(branch)
  if not Job then
    return
  end

  Job:new({
    enable_recording = true,
    command = 'git',
    args = { 'switch', '-c', branch },
    on_exit = vim.schedule_wrap(function()
      local output = vim.fn.system('git branch --show-current')
      M.log('Switched to ' .. output)
    end),
  }):start()
end

function M.get_current_user()
  local res = curl.get('https://api.app.shortcut.com/api/v3/member', { headers = headers })

  return vim.fn.json_decode(res.body)
end

function M.get_stories()
  local user = M.get_current_user()
  local query = { page_size = 25, query = string.format('owner:%s', user.mention_name), detail = 'slim' }
  local results = curl.get('https://api.app.shortcut.com/api/v3/search/stories', {
    headers = headers,
    query = query,
  })
  local resp = vim.fn.json_decode(results.body).data

  if not resp then
    return {}
  end

  return resp
end

return M
