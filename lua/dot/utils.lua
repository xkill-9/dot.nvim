local _, Job = pcall(require, 'plenary.job')

local M = {}

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = 'Dot.nvim' })
end

function M.info(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = 'Dot.nvim' })
end

--- Returns the alphanumerical words in a string separated with a dash.
--- @param name string
function M.slugify(name)
  local s = ''
  for word in string.gmatch(name, '%a+') do
    s = s .. string.lower(word) .. '-'
  end

  -- remove trailing '-'
  return string.sub(s, 1, -2)
end

---Creates a git branch and switches to it.
---@param branch string
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
