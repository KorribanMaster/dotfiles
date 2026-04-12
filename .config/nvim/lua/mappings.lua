require "nvchad.mappings"

-- add yours here
require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

local mappings = {  -- Corrected from mapppings to mappings
  n = {
    ["<leader>0"] = {
      "<cmd> NvimTreeToggle <CR>", "Nvim Tree Toggle"
    },
    ["<leader>/"] = { "<cmd> Telescope live_grep <CR>", "Search String" },
    ["<leader>fr"] = { "<cmd> Telescope oldfiles <CR>", "Recent Files" },
    -- Buffers
    ["<leader>bd"] = { ":bd<CR>", "Close buffer" },
    ["<leader>bn"] = { "<cmd> badd<CR>", "Close buffer" },
    ["<leader>bb"] = { "<cmd> Telescope buffers<CR>", "Open Buffers" },
    -- Better window navigation
    ["<C-h>"] = { "<C-w>h", "" },
    ["<C-j>"] = { "<C-w>j", "" },
    ["<C-k>"] = { "<C-w>k", "" },
    ["<C-l>"] = { "<C-w>l", "" },
    -- Resize with arrows
    ["<C-Up>"] = { ":resize -2<CR>", "" },
    ["<C-Down>"] = { ":resize +2<CR>", "" },
    ["<C-Left>"] = { ":vertical resize -2<CR>", "" },
    ["<C-Right>"] = { ":vertical resize +2<CR>", "" },
    -- Navigate buffers
    ["<S-l>"] = { ":bnext<CR>", "" },
    ["<S-h>"] = { ":bprevious<CR>", "" },
    -- 
    ["<leader>fs"] = { ":w<CR>", "Save file" },
    ["<leader>fS"] = { ":wa<CR>", "Save files" },
    ["<leader>qq"] = { ":qa<CR>", "Close all" },
    -- Diagnostics
    ["<leader>dd"] = {
      function() vim.diagnostic.open_float(nil, { scope = "line" }) end,
      "Diagnostics: floating window",
    },
    ["<leader>dv"] = {
      function()
        local cfg = vim.diagnostic.config()
        if type(cfg.virtual_lines) == "table" and cfg.virtual_lines.current_line then
          vim.diagnostic.config { virtual_lines = true }
        elseif cfg.virtual_lines == true then
          vim.diagnostic.config { virtual_lines = false }
        else
          vim.diagnostic.config { virtual_lines = { current_line = true } }
        end
      end,
      "Diagnostics: cycle virtual_lines",
    },
    ["<leader>dn"] = { function() vim.diagnostic.goto_next() end, "Next diagnostic" },
    ["<leader>dp"] = { function() vim.diagnostic.goto_prev() end, "Prev diagnostic" },
    ["<leader>fm"] = {
      function() require("conform").format { lsp_fallback = true } end,
      "Format file",
    },
  },
  i = {
    ["jk"] = { "<ESC>", "escape insert mode", opts = { nowait = true } },
  }
}

-- Function to iterate over the mappings and call map
local function apply_mappings(x)
  for mode, keys in pairs(x) do
    for key, value in pairs(keys) do
      local command = value[1]
      local desc = value[2]
      local opts = value.opts or {}
      opts.desc = desc
      map(mode, key, command, opts)
    end
  end
end

apply_mappings(mappings)

