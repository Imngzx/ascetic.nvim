---@class AsceticConfig
---@field enabled? boolean
---@field threshold? integer
---@field timeout? integer
---@field keys? string[]
---@field smart_j_k? boolean
---@field message? string | fun(key: string): string
---@field notify? fun(msg: string)

local M = {}

---@type AsceticConfig
local default_config = {
  enabled = true,
  threshold = 10,
  timeout = 2000,
  keys = { 'h', 'j', 'k', 'l', '+', '-' },
  smart_j_k = false,
  message = 'Hold it! Use Flash or motion keys (w, b, e) instead. Stop spamming `%s`!',
  notify = function(msg)
    pcall(vim.notify, msg, vim.log.levels.WARN, {
      title = 'Ascetic',
      id = 'ascetic_spam_blocker',
    })
  end,
}

local config = vim.deepcopy(default_config)

--- enable
function M.enable()
  config.enabled = true
  if type(config.notify) == 'function' then
    config.notify("🧘 Ascetic mode: Enabled")
  end
end

--- disable
function M.disable()
  config.enabled = false
  if type(config.notify) == 'function' then
    config.notify("🍺 Ascetic mode: Disabled")
  end
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
  config = vim.tbl_deep_extend('force', config, opts or {})

  vim.api.nvim_create_user_command('AsceticEnable', M.enable, { desc = 'Enable ascetic.nvim' })
  vim.api.nvim_create_user_command('AsceticDisable', M.disable, { desc = 'Disable ascetic.nvim' })
  vim.api.nvim_create_user_command('AsceticToggle', M.toggle, { desc = 'Toggle ascetic.nvim' })

  local now = vim.uv.now
  local states = {}

  for _, key in ipairs(config.keys) do
    states[key] = { count = 0, last_time = 0 }

    vim.keymap.set({ 'n', 'x' }, key, function()
      local exec_key = key
      if config.smart_j_k and (key == 'j' or key == 'k') and vim.v.count == 0 then
        exec_key = 'g' .. key
      end

      if not config.enabled then
        return exec_key
      end

      if vim.v.count > 0 then
        states[key].count = 0
        return exec_key
      end

      if vim.bo.buftype ~= '' then
        return exec_key
      end

      local current_time = now()
      local state = states[key]

      if current_time - state.last_time > config.timeout then
        state.count = 0
      end

      state.last_time = current_time
      state.count = state.count + 1

      if state.count >= config.threshold then
        local msg_cfg = config.message
        local msg = ""

        if type(msg_cfg) == 'function' then
          msg = msg_cfg(key)
        else
          ---@cast msg_cfg string
          msg = string.format(msg_cfg, key)
        end

        if type(config.notify) == 'function' then
          config.notify(msg)
        end
        return ''
      end

      return exec_key
    end, { expr = true, silent = true, desc = 'Ascetic motion ' .. key })
  end
end

return M
