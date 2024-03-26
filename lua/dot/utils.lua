local curl = require('plenary.curl')
local _, Job = pcall(require, 'plenary.job')

local M = {}

function M.info(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = 'Dot.nvim' })
end

function M.slugify(name)
  local s = ''
  for word in string.gmatch(name, '%a+') do
    s = s .. string.lower(word) .. '-'
  end

  -- remove trailing '-'
  s = string.sub(s, 1, -2)

  -- limit to 40 characters
  return string.sub(s, 1, 40)
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
      M.info('Switched to ' .. output)
    end),
  }):start()
end

return M
