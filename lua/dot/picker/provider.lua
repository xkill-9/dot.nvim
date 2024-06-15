local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local vim = vim

local utils = require('dot.utils')
local shortcut = require('dot.shortcut')
local make_entry = require('dot.picker.make_entry')

local M = {}

local function open_in_browser()
  return function(prompt_bufnr)
    local entry = action_state.get_selected_entry(prompt_bufnr)
    actions.close(prompt_bufnr)
    if entry.value.app_url then
      utils.open_in_browser_raw(entry.value.app_url)
    end
  end
end

function M.stories(opts)
  local theme_opts = require('telescope.themes').get_dropdown({})
  opts = vim.tbl_deep_extend('force', theme_opts, opts or {})

  utils.info('Fetching Stories ...')
  local stories = shortcut.get_stories()

  local max_id_length = -1
  for _, story in ipairs(stories) do
    if #tostring(story.id) > max_id_length then
      max_id_length = #tostring(story.id)
    end
  end

  pickers
    .new(opts, {
      prompt_title = 'Stories',
      finder = finders.new_table({
        results = shortcut.get_stories(),
        entry_maker = make_entry.make_from_story(max_id_length),
      }),
      sorter = config.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          utils.git_create_branch(selection.branch)
        end)
        map('i', '<C-o>', open_in_browser())
        return true
      end,
    })
    :find()
end

return M
