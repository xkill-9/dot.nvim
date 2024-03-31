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
---@param max_id_length number
function M.make_from_story(max_id_length)
  return function(story)
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
          { width = max_id_length },
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
end

return M
