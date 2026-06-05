---@class AsceticConfig
---@field enabled? boolean
---@field threshold? integer
---@field timeout? integer
---@field keys? string[]
---@field smart_j_k? boolean
---@field message? string | fun(key: string): string
---@field notify? fun(msg: string)

local M = {}

local api = vim.api
local uv = vim.uv
local v = vim.v
local bo = vim.bo
local keymap = vim.keymap
local str_format = string.format
local tbl_extend = vim.tbl_deep_extend
local now = uv.now

---@type AsceticConfig
local default_config = {
  enabled = true,
  threshold = 10,
  timeout = 2000,
  keys = { 'h', 'j', 'k', 'l', '+', '-' },
  smart_j_k = false,
  message = 'Hold it! Use Flash or motion keys (w, b, e) instead. Stop spamming `%s`!',
  notify = function(msg)
    pcall(vim.notify, msg, 3, {
      title = 'Ascetic',
      id = 'ascetic_spam_blocker',
    })
  end,
}
local config = vim.deepcopy(default_config)

--- enable
function M.enable()
  config.enabled = true
  local n = config.notify
  if n then n("🧘 Ascetic mode: Enabled") end
end

--- disable
function M.disable()
  config.enabled = false
  local n = config.notify
  if n then n("🍺 Ascetic mode: Disabled") end
end

--- toggle
function M.toggle()
  if config.enabled then
    M.disable()
  else
    M.enable()
  end
end

---@param opts? AsceticConfig
function M.setup(opts)
  config = tbl_extend('force', config, opts or {})

  local create_cmd = api.nvim_create_user_command
  create_cmd('AsceticEnable', M.enable, { desc = 'Enable ascetic.nvim' })
  create_cmd('AsceticDisable', M.disable, { desc = 'Disable ascetic.nvim' })
  create_cmd('AsceticToggle', M.toggle, { desc = 'Toggle ascetic.nvim' })

  local counts = {}
  local last_times = {}

  local cfg_threshold = config.threshold
  local cfg_timeout = config.timeout
  local cfg_smart = config.smart_j_k
  local set_map = keymap.set

  for i = 1, #config.keys do
    local key = config.keys[i]
    counts[key] = 0
    last_times[key] = 0

    local is_jk = key == 'j' or key == 'k'
    local g_key = 'g' .. key

    set_map({ 'n', 'x' }, key, function()
      local c_count = v.count
      local exec_key = (cfg_smart and is_jk and c_count == 0) and g_key or key

      if not config.enabled then return exec_key end
      if c_count > 0 then
        counts[key] = 0
        return exec_key
      end
      if bo.buftype ~= '' then return exec_key end

      local current_time = now()
      local diff = current_time - last_times[key]

      local count = (diff > cfg_timeout) and 1 or (counts[key] + 1)
      counts[key] = count
      last_times[key] = current_time

      if count >= cfg_threshold then
        local msg_cfg = config.message
        local notify_fn = config.notify
        if notify_fn then
          local msg
          if type(msg_cfg) == 'function' then
            msg = msg_cfg(key)
          else
            ---@cast msg_cfg string
            msg = str_format(msg_cfg, key)
          end
          notify_fn(msg)
        end
        return ''
      end

      return exec_key
    end, { expr = true, silent = true, desc = 'Ascetic motion ' .. key })
  end
end

return M
