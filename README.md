# gnames.nvim

Neovim plugin to highlight scientific names in with biological texts.

## Install

This plugin is compatible with Neovim v0.5 and higher. It has a dependency
to `plenary` plugin.

### Plug

```viml
Plug 'nvim-lua/plenary.nvim'
Plug 'gnames/gnames.nvim'
```

### Packer

```
use {
  'gnames/gnames.nvim',
  requires {'nvim-lua/plenary.nvim'}
}
```

## Configuration

```viml
:lua require('gnames').setup()
```

### Configuration parameters

Default configuration:

```lua
require('gnames').setup({
  gnfinder_url = "https://gnfinder.globalnames.org/api/v1"
})
```

## Usage

Open a text that contains biological scientific names and run the command:

```viml
:GNFind
```

## Development

```bash
git clone git@github.com:gnames/gnames.nvim
cd gnames.nvim
```

Add the project to `runtimepath` so nvim has access to the code during
development.

```bash
nvim --cmd 'set rtp+=.'
```

When nvim started, run once:

```vim
:luafile dev/init.lua
```

To refresh plugin use `,r`

To find names `,f`
