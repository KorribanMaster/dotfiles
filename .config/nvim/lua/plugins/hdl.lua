return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "vhdl", "systemverilog", "tcl" })
    end,
    init = function()
      vim.filetype.add {
        extension = {
          xdc = "tcl",
          ucf = "tcl",
          sv = "systemverilog",
          svh = "systemverilog",
          vh = "verilog",
        },
      }
    end,
  },
  {
    "KorribanMaster/wavedrom-nvim",
    dependencies = { "3rd/image.nvim" },
    ft = "markdown",
    cmd = { "WavedromRender", "WavedromClear", "WavedromToggle" },
    cond = function()
      if not vim.env.TMUX then return true end
      return vim.fn.system("tmux show-options -gv allow-passthrough 2>/dev/null"):match("^on") ~= nil
    end,
    opts = {},
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        systemverilog = { "verilator" },
        verilog = { "verilator" },
        vhdl = { "vsg" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group = vim.api.nvim_create_augroup("hdl_lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
