local entry_display = require('telescope.pickers.entry_display')
local strings = require('plenary.strings')
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

    local icon = story_type_icon_map[entry.value.story_type]

    -- Create a displayer with two columns:
    local displayer = entry_display.create({
      separator = ' ',
      items = {
        -- Story id column
        { width = 8 },
        -- Story type icon
        { width = strings.strdisplaywidth(icon) },
        -- Story name column
        { remaining = true },
      },
    })

    return displayer({
      { entry.value.id, 'TelescopeResultsNumber' },
      { icon },
      { entry.value.name },
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
