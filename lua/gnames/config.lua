local M = {
  text_ns = "gnames_text_namespace",
  names_ns = "gnames_names_namespace",
  text_hl_ns = "gnames_text_hl_namespace",
  names_hl_ns = "gnames_names_hl_namespace"
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
