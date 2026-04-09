local T = MiniTest.new_set()
local eq = MiniTest.expect.equality

T["setup"] = MiniTest.new_set()

T["setup"]["creates augroup"] = function()
  local groups = vim.api.nvim_get_autocmds({ group = "tiny-spark" })
  eq(#groups > 0, true)
end

T["setup"]["is idempotent"] = function()
  require("tiny-spark").setup()
  require("tiny-spark").setup()
  local groups = vim.api.nvim_get_autocmds({ group = "tiny-spark" })
  eq(#groups > 0, true)
end

T["setup"]["respects custom threshold"] = function()
  require("tiny-spark").setup({ threshold = 10 })
  local groups = vim.api.nvim_get_autocmds({ group = "tiny-spark" })
  eq(#groups > 0, true)
end

return T
