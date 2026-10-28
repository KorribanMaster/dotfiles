require "nvchad.autocmds"

-- NvChad's TSInstallAll ignores opts when the spec uses an opts function (plugins/hdl.lua does),
-- so resolve the merged opts through lazy instead
vim.api.nvim_create_user_command("TSInstallAll", function()
  local spec = require("lazy.core.config").plugins["nvim-treesitter"]
  local opts = require("lazy.core.plugin").values(spec, "opts", false)
  require("nvim-treesitter").install(opts.ensure_installed)
end, {})
