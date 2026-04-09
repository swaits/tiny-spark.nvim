-- Minimal init for testing tiny-spark.nvim
vim.opt.rtp:prepend(".")
vim.opt.rtp:prepend("deps/mini.nvim")
vim.cmd("runtime plugin/tiny-spark.lua")
