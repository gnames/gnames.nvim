local M = {
  text_ns = "gnames_text_namespace",
  panel_ns = "gnames_panel_namespace"
}

M.hi_groups = {
  Exact = "GNExactMatch",
  Fuzzy = "GNFuzzyMatch",
  PartialExact = "GNPartialExactMatch",
  PartialFuzzy = "GNPartialFuzzyMatch",
  NoMatch = "GNNoMatch"
}

M.keybindings = {
  key_down = "down",
  key_up = "up"
}

return M
