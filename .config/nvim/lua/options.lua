require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

vim.diagnostic.config {
  virtual_text = {
    prefix = "●",
    spacing = 2,
    source = "if_many",
  },
  virtual_lines = { current_line = true },
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
    wrap = true,
    max_width = 100,
  },
  severity_sort = true,
  update_in_insert = false,
}
