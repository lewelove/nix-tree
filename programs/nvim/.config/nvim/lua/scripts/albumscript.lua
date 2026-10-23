local M = {}

function M.process_metadata()
  -- Store current register states
  local saved_unnamed = vim.fn.getreginfo('"')
  local saved_clipboard = vim.fn.getreginfo('+')

  -- Read buffer lines
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local has_album_gain = vim.fn.search('^replaygain_album_gain = ', 'nw') > 0
  local has_albumartists = vim.fn.search('^albumartists = ', 'nw') > 0

  -- Identify all ARTIST lines
  local artist_lines = {}
  for _, line in ipairs(lines) do
    if line:match("^artist = ") then
      table.insert(artist_lines, line)
    end
  end

  local all_artists_same = #artist_lines > 0
  for i = 2, #artist_lines do
    if artist_lines[i] ~= artist_lines[1] then
      all_artists_same = false
      break
    end
  end

  -- General Deletions (Black hole) - original_date removed from here
  vim.cmd([[silent! %g/^\(replaygain_track_peak\|replaygain_album_peak\|original_yyyy_mm\|date_added\) = /d _]])

  -- Conditional original_date Deletion
  local orig_year, date_year
  for _, line in ipairs(lines) do
    local oy = line:match('^original_date%s*=%s*["\']?(%d%d%d%d)%-00["\']?%s*$')
    if oy then
      orig_year = oy
    end
    local dy = line:match('^date%s*=%s*["\']?(%d%d%d%d)["\']?%s*$')
    if dy then
      date_year = dy
    end
  end

  if orig_year and date_year and orig_year == date_year then
    vim.cmd([[silent! %g/^original_date = /d _]])
  end

  -- Conditional Artist Deletion
  if all_artists_same then
    vim.cmd([[silent! %g/^artist = /d _]])
  end

  -- Conditional Gain Removal
  if has_album_gain then
    vim.cmd([[silent! %g/^replaygain_track_gain = /d _]])
  end
  vim.cmd([[silent! %g/^replaygain_album_gain = /d _]])

  -- Swap Album/Artist Order
  vim.cmd([[silent! %s/^\(album = .*\)\n\(albumartists\? = .*\)/\2\r\1/ge]])

  -- Formatting (Numbers & Quotes)
  vim.cmd([[silent! %s/tracknumber = "0*\(\d\+\)"/tracknumber = \1/ge]])
  vim.cmd([[silent! %s/discnumber = "0*\(\d\+\)"/discnumber = \1/ge]])

  -- Whitespace Management
  vim.cmd([[silent! %s/^\[album\]$/[album]\r/ge]])
  vim.cmd([[silent! %s/\n\{3,}/\r\r/ge]])

  -- Save
  vim.cmd("silent! write")

  -- Restore Registers
  vim.fn.setreg('"', saved_unnamed)
  vim.fn.setreg('+', saved_clipboard)
end

return M
