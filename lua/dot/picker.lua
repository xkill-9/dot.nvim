local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local utils = require('dot.utils')
local shortcut = require('dot.shortcut')
local vim = vim

local M = {}

function M.stories(opts)
  local theme_opts = require('telescope.themes').get_dropdown({})
  opts = vim.tbl_deep_extend('force', theme_opts, opts or {})
  pickers
    .new(opts, {
      prompt_title = 'Stories',
      finder = finders.new_table({
        results = shortcut.get_stories(),
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
          }
        end,
      }),
      sorter = config.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local branch = shortcut.get_story_branch(selection.value.id, selection.value.name)
          utils.git_create_branch(branch)
        end)
        return true
      end,
    })
    :find()
end

return M
