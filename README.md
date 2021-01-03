# zsh Completion Server

A tool for scraping available completions from zsh.  Originally designed for
feeding those completions to [Talon](https://talonvoice.com) to expose zsh
completion options as voice commands.

## Installation

1. Create a socket directory that is world-writable in `/run`:

```sh
sudo mkdir /run/zsh-completion-server
sudo chmod 777 /run/zsh-completion-server
```

2. Configure `systemd` to recreate that socket directory after reboots:

```sh
echo "d /run/zsh-completion-server 0777 root root -" \
    | sudo tee /etc/tmpfiles.d/zsh-completion-server.conf
```

3. Add a line to your `~/.zshrc` to source `setup.zsh`:

```sh
# ~/.zshrc
source path/to/zsh-completion-server/setup.zsh
```

## License

The files in `fn/` were copied with modification from the
[zsh4humans](https://github.com/romkatv/zsh4humans) project, which is under the
MIT license (Copyright (c) 2020 Roman Perepelitsa).  The modifications from
those original files and all additional files in this repository are public
domain, as described by the [Unlicense](https://unlicense.org).
