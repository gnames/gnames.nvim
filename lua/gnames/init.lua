require("gnames.settings")
local config = require("gnames.config")
local gnf = require("gnames.finder")
local util = require("gnames.util")

local commands = {
  -- Finds scientific names in a current buffer and highlights them
  "command! GNFind lua require('gnames.finder').find()",
  -- Removes highlighs
  "command! GNClear lua require('gnames.finder').clear()",
  -- Toggles side panel with list of found names
  "command! GNPanelToggle lua require('gnames.panel').toggle()"
}

local setup = function(opts)
  config = util.merge_tables(config, opts or {})
  for _, v in pairs(commands) do
    vim.api.nvim_command(v)
  end
end

return {
  setup = setup,
  find = gnf.find
}
