# gnames.nvim

Neovim plugin to highlight scientific names in with biological texts.

## Prerequisites

1. This plugin requires internet for name verification.

2. The plugin uses a command line tool [gnfinder]. You can install with
   [homebrew] if available on your system, or copy an executable for your
   operating system according to [instructions][gnfinder install].

    ```bash
    brew tap gnames/gn
    brew install gnfinder
    ```

## Install

This plugin is compatible with Neovim v0.5 and higher. It has a dependency
to `plenary` plugin.

### Plug

```viml
Plug 'nvim-lua/plenary.nvim'
Plug 'gnames/gnames.nvim'
```

### Packer

```lua
use {
  'gnames/gnames.nvim',
  requires = {'nvim-lua/plenary.nvim'}
}
```

## Configuration

```viml
lua require('gnames').setup()
```

## Usage

Open a text that contains biological scientific names and run the command:

```viml
:GNFind
```

To remove highlights:

```viml
:GNClear
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

[gnfinder]: https://github.com/gnames/gnfinder
[gnfinder install]: https://github.com/gnames/gnfinder#install-as-a-command-line-app
