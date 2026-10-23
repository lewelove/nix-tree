local M = {}

function M.quick_save()
  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local bt = vim.bo[buf].buftype

  -- Guard: Only allow execution on completely empty, unnamed buffers
  if buf_name ~= "" or bt ~= "" then
    vim.notify("Quick Save only works in empty, unnamed buffers!", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Function to strip leading and trailing empty lines
  local function strip_empty_lines()
    while #lines > 0 and not lines[1]:match("%S") do
      table.remove(lines, 1)
    end
    while #lines > 0 and not lines[#lines]:match("%S") do
      table.remove(lines, #lines)
    end
  end

  strip_empty_lines()

  if #lines == 0 then
    vim.notify("Buffer is empty. Nothing to save.", vim.log.levels.WARN)
    return
  end

  local target_dir = vim.fn.expand("~/Notes")
  local first_line = lines[1]
  local trimmed_first = vim.trim(first_line)
  local routed = false

  local routes = {
    n = "~/Notes/",
    vellumIdeas = "~/dev/vellum/exp/ideas/",
    vellumActions = "~/dev/vellum/exp/ideas/actions/",
    vellumNotes = "~/dev/vellum/ext/notes/",
    vellumTodo = "~/dev/vellum/exp/todo/",
    mute = "~/dev/mute/docs/ideas/",
    nv = "~/Notes/config/nv/",
    hypr = "~/Notes/config/hypr/",
  }

  -- Route parsing based on first line
  if trimmed_first == "!" then
    target_dir = vim.fn.expand("~/Notes/todo")
    routed = true
  elseif trimmed_first:match("^#") then
    local proj = trimmed_first:sub(2):match("^%s*(.-)%s*$")
    if routes[proj] then
      target_dir = vim.fn.expand(routes[proj])
    else
      if proj == "" then
        target_dir = vim.fn.expand("~/Notes/projects")
      else
        proj = proj:gsub('[<>:"/\\|%?%*]', "_") -- Sanitize folder name
        target_dir = vim.fn.expand("~/Notes/projects/" .. proj)
      end
    end
    routed = true
  end

  -- Remove the routing symbol line and re-strip in case of space before title
  if routed then
    table.remove(lines, 1)
    strip_empty_lines()
  end

  if #lines == 0 then
    vim.notify("No actual content left after removing prefix!", vim.log.levels.WARN)
    return
  end

  -- Strip trailing whitespace from the end of every individual line
  for i, line in ipairs(lines) do
    lines[i] = line:gsub("%s+$", "")
  end

  -- Grab the new first line to generate filename
  local title_line = lines[1]
  local clean_title = title_line:gsub("^#+%s*", "")
  clean_title = vim.trim(clean_title)
  clean_title = clean_title:gsub('[<>:"/\\|%?%*]', "_")
  clean_title = clean_title:gsub("^%.+", "")
  clean_title = clean_title:gsub("%s+", "-")

  -- Cap at 64 characters
  if #clean_title > 64 then
    clean_title = vim.fn.strcharpart(clean_title, 0, 64):match("^(.-)[-%s]*$")
  end
  if clean_title == "" then clean_title = "untitled" end

  -- Format
  local filename = clean_title .. ".md"
  local full_path = target_dir .. "/" .. filename

  -- Update buffer visually with the cleaned version
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Ensure directory exists
  if vim.fn.isdirectory(target_dir) == 0 then
    vim.fn.mkdir(target_dir, "p")
  end

  -- Save and attach the buffer to the file
  vim.api.nvim_buf_set_name(buf, full_path)
  local success, err = pcall(function()
    vim.cmd("write!")
  end)

  if success then
    vim.notify("Saved to: " .. full_path, vim.log.levels.INFO)
    -- Reset filetype to text/markdown if preferred
    vim.bo[buf].filetype = "markdown"
    vim.cmd("qa!")
  else
    vim.notify("Failed to save note: " .. tostring(err), vim.log.levels.ERROR)
  end
end

return M
