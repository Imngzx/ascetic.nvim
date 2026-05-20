---@class AsceticConfig
---@field enabled? boolean
---@field threshold? integer
---@field timeout? integer
---@field keys? string[]
---@field smart_j_k? boolean

local M = {}

---@type AsceticConfig
local default_config = {
  enabled = true,
  threshold = 10,
  timeout = 2000,
  keys = { 'h', 'j', 'k', 'l', '+', '-' },
  smart_j_k = false,
}

local config = vim.deepcopy(default_config)

---@param opts? AsceticConfig
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})

  if not config.enabled then return end

  local now = vim.uv.now
  local states = {}

  for _, key in ipairs(config.keys) do
    states[key] = { count = 0, last_time = 0 }

    vim.keymap.set('n', key, function()
      local exec_key = key
      if config.smart_j_k then
        if key == 'j' then exec_key = 'gj' end
        if key == 'k' then exec_key = 'gk' end
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
        pcall(vim.notify, 'Hold it! Use Enter, Flash or motion keys (w, b, e) instead.', vim.log.levels.WARN, {
          title = 'Ascetic',
          id = 'ascetic_spam_blocker',
        })
        return ''
      end

      return exec_key
    end, { expr = true, silent = true, desc = 'Ascetic motion ' .. key })
  end
end

return M
