require("gnames.settings")
local config = require("gnames.config")
local gnf = require("gnames.finder")
local util = require("gnames.util")

local commands = {
  "command! GNFind lua require('gnames.finder').find()"
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
