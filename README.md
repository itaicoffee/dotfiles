# dotfiles

Personal macOS dotfiles: zsh, yabai/skhd window management, WezTerm, xbar
plugins, and helper scripts in `bin/`.

## Install

```
make install
```

Installs Homebrew packages (yabai, skhd, xbar, wezterm, zoxide), symlinks
configs into `~/.config`, links `bin/` scripts into `~/.local/bin`, and sets
up `~/.zshrc`. No `sudo` required.

Machine-specific settings (env vars, Chrome profile mappings) live in
`~/.profile`, which is created locally and **never committed**. To map Chrome
profiles, run separately:

```
make check-chrome-profiles
```

## Lint

```
make lint
```

## Uninstall

```
make uninstall
```

Older installs symlinked scripts into `/usr/local/bin`; remove those legacy
links with:

```
make cleanup-legacy-bin   # needs sudo
```

## Secrets

To decrypt `secrets.enc`, run

```
openssl aes-256-cbc -d -a -in secrets.enc
```

and enter the password.

When re-encrypting, use the modern KDF (the legacy format uses a weak
one-iteration digest):

```
openssl aes-256-cbc -salt -pbkdf2 -iter 200000 -a -in secrets.txt -out secrets.enc
```
