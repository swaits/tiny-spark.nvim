# tiny-spark.nvim

A tiny cursor jump animation for Neovim 0.12+. Flashes a brief highlight
at the cursor position after large jumps.

Zero config. ~55 lines of Lua.

## Features

- Brief flash at cursor position after jumping 5+ lines
- Smooth fade-out animation via `winblend`
- Configurable threshold, duration, width, and highlight group
- Extremely lightweight — no dependencies, single timer
- Works out of the box — no setup call required

## Requirements

- Neovim >= 0.12
- A terminal that supports `winblend` (most modern terminals)

## Installation

Add to your `vim.pack.add()` call:

```lua
"https://github.com/swaits/tiny-spark.nvim",
```

## Configuration

All options are optional. Call `setup()` only if you want to customize:

```lua
require("tiny-spark").setup({
  threshold = 5,        -- minimum line distance to trigger
  duration = 150,       -- fade duration in ms
  width = 8,            -- flash width in columns
  hl = "CurSearch",     -- highlight group
})
```

## How it works

On `CursorMoved`, the plugin compares the current cursor line to the
previous one. If the distance exceeds the threshold, it opens a small
floating window at the cursor position and fades it out by increasing
`winblend` from 0 to 100 over the configured duration.

## License

[MIT](LICENSE)
