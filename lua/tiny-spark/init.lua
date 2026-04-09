local M = {}

function M.setup(opts)
  opts = opts or {}
  local threshold = opts.threshold or 3
  local duration = opts.duration or 50
  local step = math.ceil(1000 / 60)
  local prev = { 0, 0 }
  local ns = vim.api.nvim_create_namespace("tiny-spark")

  local trail_chars = opts.chars or { "░", "▒", "▓", "█" }
  local palette = opts.palette
    or {
      { fg = "#552200" },
      { fg = "#cc4400" },
      { fg = "#ff8822" },
      { fg = "#ffcc44" },
      { fg = "#ffffff", bold = true },
    }
  for i, def in ipairs(palette) do
    vim.api.nvim_set_hl(0, "TinySpark" .. i, def)
  end

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("tiny-spark", { clear = true }),
    callback = function()
      local cur = vim.api.nvim_win_get_cursor(0)
      local dy = cur[1] - prev[1]
      local dx = cur[2] - prev[2]
      local dist = math.abs(dy)
      local old_prev = { prev[1], prev[2] }
      prev = cur
      if dist < threshold then
        return
      end

      local buf = vim.api.nvim_get_current_buf()
      local line_count = vim.api.nvim_buf_line_count(buf)
      local dir = dy > 0 and 1 or -1

      -- Build trail from origin to destination
      local trail = {}
      for i = 0, dist - 1 do
        local t = dist > 1 and i / (dist - 1) or 1
        local row = old_prev[1] - 1 + dir * i
        local col = old_prev[2] + math.floor(dx * t + 0.5)
        if row >= 0 and row < line_count and col >= 0 then
          table.insert(trail, { row = row, col = col })
        end
      end

      local elapsed = 0
      local timer = vim.uv.new_timer()
      timer:start(
        0,
        step,
        vim.schedule_wrap(function()
          elapsed = elapsed + step
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

          if elapsed >= duration or not vim.api.nvim_buf_is_valid(buf) or #trail == 0 then
            timer:stop()
            if not timer:is_closing() then
              timer:close()
            end
            return
          end

          -- Shrink trail from origin end (remove the dark/far end first)
          local progress = elapsed / duration
          local drop = math.floor(#trail * progress)
          local start = drop + 1

          for i = start, #trail do
            local p = trail[i]
            -- t=0 at start of visible trail (dimmest), t=1 at destination (brightest)
            local t = (#trail - start) > 0 and (i - start) / (#trail - start) or 1
            local char_idx = math.max(1, math.min(#trail_chars, math.ceil(t * #trail_chars)))
            local hl_idx = math.max(1, math.min(#palette, math.ceil(t * #palette)))
            pcall(vim.api.nvim_buf_set_extmark, buf, ns, p.row, 0, {
              virt_text = { { trail_chars[char_idx], "TinySpark" .. hl_idx } },
              virt_text_pos = "overlay",
              virt_text_win_col = p.col,
            })
          end
        end)
      )
    end,
  })
end

return M
