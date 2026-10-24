# Vasuper Sway Spin

Personal bootc image: Sway on `ghcr.io/ublue-os/bluefin-dx:stable-daily`. GNOME stays; GDM offers both sessions. Image name and org come from `image-template.env`.

## Where changes go

- Packages, COPR repos, `/etc/environment`, and service enables: `build_files/build.sh`. It runs inside the image build. `dnf5` fails if a package is already in the base — only add packages that are not already installed.
- Disable any COPR you enable before the script exits. Do not leave extra repos enabled in the image.
- Immutable system files (`/usr/share/sway`, `/etc/sway`, the GDM session): `system_files/`, copied onto `/`.
- New-user dotfiles: `homefiles/`, copied onto `/etc/skel/`. Existing accounts do not pick these up until they copy from skel.
- Base image and the `build.sh` mount: `Containerfile`. End the image with `bootc container lint`.
- Local and CI recipes: `Justfile`. Prefer `just build`, `just lint`, and `just format` over ad-hoc commands.

## Conventions

- Bash scripts use `set -ouex pipefail` (or `set -eoux pipefail` in Just recipes). Run `just lint` and `just format` after editing `*.sh`.
- Sway theme is Catppuccin Mocha. Mod key is Super. Keep bar, lock, launcher, notifications, and terminal colors in that palette.
- Session scripts live under `/usr/share/sway/scripts/` and are updated on rebase. User config only sources them.
- Never commit `cosign.key`. It is gitignored; `cosign.pub` is the public key that belongs in the repo.
- Do not commit `output/`, `_build*`, or chunkah/rpm-ostree work directories.

## Verify

```bash
just lint
just build
```

`just build` needs podman and a clean enough tree if you want git SHA labels. A full VM boot is `just run-vm` (serves a viewer on localhost port 8006).
