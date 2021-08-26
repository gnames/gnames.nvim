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
Plug 'gnames/gnames.nvim'
```

### Packer

```lua
use 'gnames/gnames.nvim'
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

### Dealing with files that contain BOM <FEFF> characters

BOM are zero-length characters that are invisible for most editors. They might appear in a text file because of an OCR errors or to indicate UTF encoding. These characters are invisible for name-finding tool and
they interfere with highlighing. To remove them you can use the following
`awk` command:

```awk
awk '{ gsub(/\xef\xbb\xbf/,""); print }' INFILE > OUTFILE
```

Also, see this [StackOverflow question][nobom]

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
[nobom]: https://stackoverflow.com/questions/7297888/0xef-0xbb-0xbf-character-showing-up-in-files-how-to-remove-them
