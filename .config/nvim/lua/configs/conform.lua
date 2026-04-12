local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    systemverilog = { "verible_verilog_format" },
    verilog = { "verible_verilog_format" },
    vhdl = { "vsg" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  formatters = {
    vsg = {
      command = "vsg",
      args = { "-f", "$FILENAME", "--fix" },
      stdin = false,
    },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
