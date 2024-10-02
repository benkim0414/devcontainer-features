# Dev Container Features

### Neovim

Install Neovim built from source.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/benkim0414/devcontainer-features/neovim:1": {
            "version": "stable"
        }
    }
}
```

### LazyVim

Install and configure LazyVim under [XDG_CONFIG_HOME](https://specifications.freedesktop.org/basedir-spec/latest/), which is `$HOME/.config`.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/benkim0414/devcontainer-features/lazyvim:1": {}
    }
}
```
