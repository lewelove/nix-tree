local M = {}

--- Convert a single timestamp string to ISO 8601 UTC Zulu (-3h offset)
local function convert_match(m_str, d_str, y_str, H_str, M_str, S_str)
  local m = tonumber(m_str)
  local d = tonumber(d_str)
  local y = tonumber(y_str)
  local H = tonumber(H_str)
  local min = tonumber(M_str)
  local sec = tonumber(S_str)

  -- Expand 2-digit years (e.g. 26 -> 2026)
  if y < 100 then
    y = y + 2000
  end

  -- Calculate epoch and subtract 3 hours (3 * 3600 seconds)
  local epoch = os.time({
    year = y,
    month = m,
    day = d,
    hour = H,
    min = min,
    sec = sec,
    isdst = false,
  }) - (3 * 3600)

  local dt = os.date("*t", epoch)
  return string.format("%04d-%02d-%02dT%02d:%02d:%02d.000Z",
    dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
end

--- Process a line and replace all Telegram timestamp occurrences
function M.convert_line(line)
  local pattern = "(%d+)/(%d+)/(%d+)%s+at%s+(%d+):(%d+):(%d+)"
  local new_line, count = line:gsub(pattern, convert_match)
  return new_line, count
end

--- Process command range (current line, visual selection, or whole file)
function M.process_range(opts)
  local start_line = opts.line1 - 1
  local end_line = opts.line2
  local buf = vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
  local total_converted = 0

  for i, line in ipairs(lines) do
    local converted, count = M.convert_line(line)
    if count > 0 then
      lines[i] = converted
      total_converted = total_converted + count
    end
  end

  if total_converted > 0 then
    vim.api.nvim_buf_set_lines(buf, start_line, end_line, false, lines)
    vim.notify(string.format("TeleTime: Converted %d timestamp(s).", total_converted), vim.log.levels.INFO)
  else
    vim.notify("TeleTime: No matching timestamps found.", vim.log.levels.WARN)
  end
end

return M
