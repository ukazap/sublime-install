# Sublime Text & Sublime Merge Installer for Linux

Downloads, verifies, and installs Sublime Text and Sublime Merge on Linux.

Requires: `curl`, `gpg`, `tar`, `sudo`.

## Install Both
```bash
make install
```

## Install Individual
```bash
make install-sublime-text
make install-sublime-merge
```

## Other Commands
- `make uninstall` - Remove both
- `make uninstall-sublime-text` - Remove Sublime Text
- `make uninstall-sublime-merge` - Remove Sublime Merge
- `make clean` - Delete downloads
