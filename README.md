# gnames.nvim

Neovim plugin to work with biological texts.

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
