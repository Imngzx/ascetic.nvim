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
})
```
