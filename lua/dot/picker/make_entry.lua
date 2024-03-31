local entry_display = require('telescope.pickers.entry_display')
local shortcut = require('dot.shortcut')
local M = {}

local story_type_icon_map = {
  feature = '',
  bug = '',
  chore = '',
}

---Creates a telescope entry from a Story
---@param story Story
function M.from_story(story)
  local make_display = function(entry)
    if not entry then
      return nil
    end

    -- Create a displayer with two columns:
    local displayer = entry_display.create({
      separator = ' ',
      items = {
        -- Story id column
        { width = 8 },
        -- Story name column
        { remaining = true },
      },
    })

    local icon = story_type_icon_map[entry.value.story_type] or ''

    return displayer({
      { entry.value.id, 'TelescopeResultsNumber' },
      { icon .. ' ' .. entry.value.name },
    })
  end

  return {
    value = story,
    display = make_display,
    ordinal = story.id .. ' ' .. story.name,
    branch = shortcut.get_story_branch(story.id, story.name),
  }
end

return M
