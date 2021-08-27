package.loaded["dev"] = nil
package.loaded["gnames"] = nil
package.loaded["gnames.util"] = nil
package.loaded["gnames.config"] = nil
package.loaded["gnames.panel"] = nil
package.loaded["gnames.finder"] = nil

vim.api.nvim_set_keymap("n", ",r", ":luafile dev/init.lua<cr>", {})

GN = require("gnames")

GN.setup()

vim.api.nvim_set_keymap("n", ",f", ":lua GN.find()<cr>", {})
