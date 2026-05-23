# 🧘 Ascetic.nvim (苦行僧)

> Stop spamming `j` and `k`. Practice Neovim discipline.

Are you addicted to holding `j` and `k` to scroll through your files? **ascetic.nvim** is a minimalist, highly-optimized Neovim plugin designed to break your bad habits. 

If you spam basic movement keys (`h`, `j`, `k`, `l`) too many times in a short window, it will block your movement and kindly remind you to use proper Neovim motions (like `w`, `b`, `e`, `}`, or plugins like `flash.nvim`).

Embrace the ascetic lifestyle. Become a better Vimmer.

## ✨ Features

- 🚀 **Blazing Fast**: Uses `libuv` (`vim.uv.now()`) for zero-overhead, microsecond-level time tracking.
- 🧠 **Smart Context**: 
  - Allows count prefixes (e.g., `15j` works perfectly and resets the penalty counter).
  - Automatically disables itself in special buffers (terminals, floating windows, UI pickers).
- 🔄 **Smart Wrap (`gj`/`gk`)**: Built-in support to seamlessly remap `j`/`k` to `gj`/`gk` for wrapped lines.
- 💡 **Lazydev Ready**: Fully typed with LuaCATS. Enjoy perfect autocomplete and type checking for your `opts`.

![Preview Video](https://github.com/user-attachments/assets/51f33233-2902-420b-a795-9b7309632d86)

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "Imngzx/ascetic.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- Your configuration comes here
    -- or leave it empty to use the default settings
  }
}
```

Using `vim.pack`
```lua
vim.pack.add('https://github.com/Imngzx/ascetic.nvim')
```

# Configuration
`ascetic.nvim` comes with sane defaults. Here is the default configuration

```lua
require("ascetic").setup({
  -- Enable or disable the plugin
  enabled = true,
  
  -- The maximum number of consecutive keystrokes allowed
  threshold = 10,
  
  -- The time window (in milliseconds) for the threshold
  timeout = 2000,
  
  -- The keys to track and discipline
  keys = { 'h', 'j', 'k', 'l', '+', '-' },
  
  -- If true, 'j' and 'k' will behave as 'gj' and 'gk' (respecting line wrap)
  smart_j_k = false, 

  -- The warning message. `%s` will be replaced by the blocked key.
  -- Can be a string or a callback function: `fun(key: string): string`
  message = 'Hold it! Use Enter, Flash or motion keys (w, b, e) instead. Stop spamming `%s`!',

  -- The function used to display the warning.
  -- Default uses `vim.notify` with an ID to prevent spamming the screen.
  notify = function(msg)
    pcall(vim.notify, msg, vim.log.levels.WARN, {
      title = 'Ascetic',
      id = 'ascetic_spam_blocker',
    })
  end,
})
```

## 🎨 Notification Recipes

Because the UI is completely decoupled, you can easily customize how warnings are displayed. Here are a few popular setups:

### 1. 🍿 Snacks.nvim Integration
If you are using the popular [Snacks.nvim](https://github.com/folke/snacks.nvim) notifier:
```lua
opts = {
  message = "Stop spamming `%s`! Practice discipline.",
  notify = function(msg)
    Snacks.notifier.notify(msg, "warn", { 
      title = "Ascetic", 
      id = "ascetic_spam" 
    })
  end,
}
```

### 2. 🥷 Minimalist Native Mode (No popups)
If you hate popups and just want a discreet red message in your command line:
```lua
opts = {
  message = "Stop spamming `%s`!",
  notify = function(msg)
    -- Uses raw nvim_echo. Bypasses notify plugins and leaves no trace.
    vim.api.nvim_echo({{ "[Ascetic] " .. msg, "WarningMsg" }}, false, {})
  end,
}
```

### 3. 🤡 Custom Dynamic Message
You can pass a function to `message` to return dynamic strings:
```lua
opts = {
  message = function(key)
    local insults = {
      j = "Down down down... use `C-d` bro!",
      k = "Up up up... use `C-u` instead!",
    }
    return insults[key] or ("Stop pressing `%s`!"):format(key)
  end,
}
```

## ⌨️ Commands & API

Need to record a macro or do some repetitive work? You can easily toggle the plugin on the fly using Neovim commands:

- `:AsceticToggle` - Toggles the plugin on/off.
- `:AsceticEnable` - Enables the plugin.
- `:AsceticDisable` - Disables the plugin.

You can also map these to a keybind using the exposed Lua API:
```lua
vim.keymap.set("n", "<leader>ta", require("ascetic").toggle, { desc = "Toggle Ascetic" })
```

## 🤝 Requirements
- Neovim >= 0.11.4 (Fully compatible with 0.12/0.13 nightly)

Here's my [configuration](https://github.com/Imngzx/nvim-config-rice-.ver-/blob/nvim-native/lua/plugins/tool.lua#L98) 

## License

This project is licensed under the MIT License.
