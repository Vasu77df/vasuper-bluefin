# Vasuper Sway Spin — Bluefin

A personal custom [Bluefin-DX](https://github.com/ublue-os/bluefin) image layering a full
[Sway](https://swaywm.org) tiling WM setup on top of the stock Bluefin GNOME desktop.
Both sessions coexist — pick Sway or GNOME at the GDM login screen.

![Screenshot](screenshot.png)

---

## What this image adds

### Base image
- `ghcr.io/ublue-os/bluefin-dx:stable-daily` — Fedora Atomic + GNOME + developer tooling

### Sway compositor stack
| Package | Purpose |
|---|---|
| `sway` | Wayland tiling compositor (i3-compatible) |
| `swaybg` | Wallpaper renderer |
| `swayidle` | Idle management (screen lock + display off) |
| `swaylock` | Lock screen |
| `swaynag` | Confirmation dialogs (power menu) |

### Wayland tooling
| Package | Purpose |
|---|---|
| `waybar` | Status bar |
| `mako` | Notification daemon |
| `wofi` | App launcher |
| `kanshi` | Automatic display profile switching |
| `wdisplays` | GUI display management |
| `grim` + `slurp` | Screenshot capture |
| `xdg-desktop-portal-wlr` | wlroots portal (screen share, file picker) |

### Audio & system control
| Package | Purpose |
|---|---|
| `pamixer` | CLI volume control (used by keybindings) |
| `pavucontrol` | GUI audio mixer |
| `brightnessctl` | Backlight control |
| `network-manager-applet` | Network tray icon |
| `blueman` | Bluetooth tray icon |

### Terminal & dev tools
| Package | Purpose |
|---|---|
| `ghostty` | GPU-accelerated terminal (via scottames/ghostty COPR) |
| `shellcheck` | Shell script linter |

### Theme
- **Catppuccin Mocha** across all components — Sway borders, Waybar, Mako,
  Wofi, Swaylock
- **IosevkaTerm Nerd Font** for bar and terminal

---

## Sway session layout

```
/usr/share/sway/scripts/     ← immutable system scripts (updated with every image rebase)
  session-start.sh           starts mako, nm-applet, kanshi, swayidle once per session
  session-action.sh          lock / suspend / logout / reboot / poweroff
  lock.sh                    swaylock with wallpaper + Catppuccin config
  power-menu.sh              swaynag power menu (Super+Shift+P)
  screenshot.sh              full / area / window capture → ~/Pictures/Screenshots/
  notification-toggle.sh     toggle mako do-not-disturb + signal waybar
  notification-status.sh     JSON status for waybar custom/notifications module
  notification-action.sh     pipe mako actions through wofi dmenu
  focused-window.sh          inspect + clipboard-copy focused window metadata

/etc/sway/config-vars.d/     ← system drop-ins sourced by every user's Sway config
  10-session.conf            exports Wayland/D-Bus session environment

/usr/share/wayland-sessions/
  sway.desktop               GDM session entry (alongside GNOME)

/etc/skel/.config/           ← seeded into ~/ for every new user at account creation
  sway/config                main config — sources system drop-ins, theme, conf.d/*
  sway/themes/catppuccin-mocha
  sway/conf.d/
    10-input.conf            keyboard repeat rate, touchpad tap + natural scroll
    20-outputs.conf          eDP-1 fallback + workspace→output affinity
    30-appearance.conf       borders, gaps, window colors, wallpaper, waybar
    40-keybindings.conf      full keybinding set (mod = Super)
    50-window-rules.conf     floating rules: dialogs, Zoom, Slack, PiP, auth prompts
    60-autostart.conf        exec session-start.sh
  waybar/config.jsonc        workspaces, clock, network, bt, cpu, mem, audio, battery
  waybar/mocha.css           Catppuccin Mocha palette
  waybar/style.css           bar styling
  mako/config                notifications with do-not-disturb mode
  wofi/config + style.css    launcher
  swaylock/config            lock screen colors
  kanshi/config              undocked + docked-dp3/5/6 display profiles
  ghostty/config             terminal — Catppuccin Mocha, IosevkaTerm, alt+hjkl splits
```

---

## Keybindings (mod = Super)

| Binding | Action |
|---|---|
| `Super+T` | Open terminal (ghostty) |
| `Super+D` / `Super+Space` | App launcher (wofi) |
| `Super+Shift+B` | Browser (firefox) |
| `Super+Ctrl+F` | File manager (nautilus) |
| `Super+Shift+Q` | Close window |
| `Super+H/J/K/L` | Focus left/down/up/right |
| `Super+Shift+H/J/K/L` | Move window |
| `Super+R` | Resize mode |
| `Super+F` | Fullscreen |
| `Super+Shift+F` | Toggle floating |
| `Super+1-9` | Switch workspace |
| `Super+Shift+1-9` | Move container to workspace |
| `Super+Escape` | Lock screen |
| `Super+Shift+P` | Power menu |
| `Super+Shift+C` | Reload Sway config |
| `Print` | Screenshot (full) |
| `Shift+Print` | Screenshot (area select) |
| `Ctrl+Print` | Screenshot (focused window) |
| `Super+N` | Dismiss notification |
| `Super+Ctrl+N` | Toggle do-not-disturb |
| `XF86AudioRaiseVolume/LowerVolume/Mute` | Volume control |
| `XF86MonBrightnessUp/Down` | Backlight control |

---

## First login after rebasing

The sway configs land in `~/.config/` automatically for new accounts.
For your **existing** user account, copy them once:

```bash
cp -r /etc/skel/.config/sway ~/.config/
cp -r /etc/skel/.config/waybar ~/.config/
cp -r /etc/skel/.config/mako ~/.config/
cp -r /etc/skel/.config/wofi ~/.config/
cp -r /etc/skel/.config/swaylock ~/.config/
cp -r /etc/skel/.config/kanshi ~/.config/
cp -r /etc/skel/.config/ghostty ~/.config/

# Drop your wallpaper in place
cp ~/Pictures/your-wallpaper.png ~/.config/sway/wallpaper.png
```

Then log out, select **Sway** at GDM, and log back in.

---

## Building and testing locally

```bash
# Build the container image
just build

# Convert to QCOW2 and boot a VM (opens http://localhost:8006)
just run-vm

# Rebuild everything from scratch
just rebuild-vm

# Wipe output and start fresh
just clean
```

## Rebasing your machine

```bash
# Rebase to the published image
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/Vasu77df/vasuper-bluefin:latest
systemctl reboot

# Or rebase to a locally built image for testing
sudo rpm-ostree rebase ostree-unverified-image:containers-storage:localhost/vasuper-bluefin:latest
systemctl reboot

# Roll back if needed
sudo rpm-ostree rollback
systemctl reboot

# Update to latest published image
ujust update
```

---
---

# image-template

This repository is meant to be a template for building your own custom [bootc](https://github.com/bootc-dev/bootc) image. This template is the recommended way to make customizations to any image published by the Universal Blue Project.

# Community

If you have questions about this template after following the instructions, try the following spaces:
- [Universal Blue Forums](https://universal-blue.discourse.group/)
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc discussion forums](https://github.com/bootc-dev/bootc/discussions) - This is not an Universal Blue managed space, but is an excellent resource if you run into issues with building bootc images.

# How to Use

To get started on your first bootc image, simply read and follow the steps in the next few headings.
If you prefer instructions in video form, TesterTech created an excellent tutorial, embedded below.

[![Video Tutorial](https://img.youtube.com/vi/IxBl11Zmq5w/0.jpg)](https://www.youtube.com/watch?v=IxBl11Zmq5wE)

## Step 0: Prerequisites

These steps assume you have the following:
- A Github Account
- A machine running a bootc image (e.g. Bazzite, Bluefin, Aurora, or Fedora Atomic)
- Experience installing and using CLI programs

## Step 1: Preparing the Template

### Step 1a: Copying the Template

Select `Use this Template` on this page. You can set the name and description of your repository to whatever you would like, but all other settings should be left untouched.

Once you have finished copying the template, you need to enable the Github Actions workflows for your new repository.
To enable the workflows, go to the `Actions` tab of the new repository and click the button to enable workflows.

### Step 1b: Cloning the New Repository

Here I will defer to the much superior GitHub documentation on the matter. You can use whichever method is easiest.
[GitHub Documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)

Once you have the repository on your local drive, proceed to the next step.

## Step 2: Initial Setup

### Step 2a: Creating a Cosign Key

Container signing is important for end-user security and is enabled on all Universal Blue images. By default the image builds *will fail* if you don't.

First, install the [cosign CLI tool](https://edu.chainguard.dev/open-source/sigstore/cosign/how-to-install-cosign/#installing-cosign-with-the-cosign-binary)
With the cosign tool installed, run inside your repo folder:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

The signing key will be used in GitHub Actions and will not work if it is password protected.

> [!WARNING]
> Be careful to *never* accidentally commit `cosign.key` into your git repo. If this key goes out to the public, the security of your repository is compromised.

Next, you need to add the key to GitHub. This makes use of GitHub's secret signing system.

<details>
    <summary>Using the Github Web Interface (preferred)</summary>

Go to your repository settings, under `Secrets and Variables` -> `Actions`
![image](https://user-images.githubusercontent.com/1264109/216735595-0ecf1b66-b9ee-439e-87d7-c8cc43c2110a.png)
Add a new secret and name it `SIGNING_SECRET`, then paste the contents of `cosign.key` into the secret and save it. Make sure it's the .key file and not the .pub file. Once done, it should look like this:
![image](https://user-images.githubusercontent.com/1264109/216735690-2d19271f-cee2-45ac-a039-23e6a4c16b34.png)
</details>
<details>
<summary>Using the Github CLI</summary>

If you have the `github-cli` installed, run:

```bash
gh secret set SIGNING_SECRET < cosign.key
```
</details>

### Step 2b: Choosing Your Base Image

To choose a base image, simply modify the line in the container file starting with `FROM`. This will be the image your image derives from, and is your starting point for modifications.
For a base image, you can choose any of the Universal Blue images or start from a Fedora Atomic system. Below this paragraph is a dropdown with a non-exhaustive list of potential base images.

<details>
    <summary>Base Images</summary>

- Bazzite: `ghcr.io/ublue-os/bazzite:stable`
- Aurora: `ghcr.io/ublue-os/aurora:stable`
- Bluefin: `ghcr.io/ublue-os/bluefin:stable`
- Universal Blue Base: `ghcr.io/ublue-os/base-main:latest`
- Fedora: `quay.io/fedora/fedora-bootc:44`

You can find more Universal Blue images on the [packages page](https://github.com/orgs/ublue-os/packages).
</details>

If you don't know which image to pick, choosing the one your system is currently on is the best bet for a smooth transition. To find out what image your system currently uses, run the following command:
```bash
sudo bootc status
```
This will show you all the info you need to know about your current image. The image you are currently on is displayed after `Booted image:`. Paste that information after the `FROM` statement in the Containerfile to set it as your base image.

### Step 2c: Changing Names

Change the `IMAGE_NAME` and `REPO_ORGANIZATION` variable inside the `image-template.env`

To commit and push all the files changed and added in step 2 into your Github repository:
```bash
git add Containerfile image-template.env cosign.pub
git commit -m "Initial Setup"
git push
```
Once pushed, go look at the Actions tab on your Github repository's page.  The green checkmark should be showing on the top commit, which means your new image is ready!

## Step 3: Switch to Your Image

From your bootc system, run the following command substituting in your Github username and image name where noted.
```bash
sudo bootc switch ghcr.io/<username>/<image_name>
```
This should queue your image for the next reboot, which you can do immediately after the command finishes. You have officially set up your custom image! See the following section for an explanation of the important parts of the template for customization.

# Repository Contents

## Containerfile

The [Containerfile](./Containerfile) defines the operations used to customize the selected image.This file is the entrypoint for your image build, and works exactly like a regular podman Containerfile. For reference, please see the [Podman Documentation](https://docs.podman.io/en/latest/Introduction.html).

## build.sh

The [build.sh](./build_files/build.sh) file is called from your Containerfile. It is the best place to install new packages or make any other customization to your system. There are customization examples contained within it for your perusal.

## build.yml

The [build.yml](./.github/workflows/build.yml) Github Actions workflow creates your custom OCI image and publishes it to the Github Container Registry (GHCR). By default, the image name will match the Github repository name.

# Building Disk Images

This template provides an out of the box workflow for creating disk images (ISO, qcow, raw) for your custom OCI image which can be used to directly install onto your machines.

This template provides a way to upload the disk images that is generated from the workflow to a S3 bucket. The disk images will also be available as an artifact from the job, if you wish to use an alternate provider. To upload to S3 we use [rclone](https://rclone.org/) which is able to use [many S3 providers](https://rclone.org/s3/).

## Setting Up ISO Builds

The [build-disk.yml](./.github/workflows/build-disk.yml) Github Actions workflow creates a disk image from your OCI image by utilizing the [bootc-image-builder](https://osbuild.org/docs/bootc/). In order to use this workflow you must complete the following steps:

1. Modify `disk_config/iso.toml` to point to your custom container image before generating an ISO image.
2. If you changed your image name from the default in `build.yml` then in the `build-disk.yml` file edit the `IMAGE_REGISTRY`, `IMAGE_NAME` and `DEFAULT_TAG` environment variables with the correct values. If you did not make changes, skip this step.
3. Finally, if you want to upload your disk images to S3 then you will need to add your S3 configuration to the repository's Action secrets. This can be found by going to your repository settings, under `Secrets and Variables` -> `Actions`. You will need to add the following
  - `S3_PROVIDER` - Must match one of the values from the [supported list](https://rclone.org/s3/)
  - `S3_BUCKET_NAME` - Your unique bucket name
  - `S3_ACCESS_KEY_ID` - It is recommended that you make a separate key just for this workflow
  - `S3_SECRET_ACCESS_KEY` - See above.
  - `S3_REGION` - The region your bucket lives in. If you do not know then set this value to `auto`.
  - `S3_ENDPOINT` - This value will be specific to the bucket as well.

Once the workflow is done, you'll find the disk images either in your S3 bucket or as part of the summary under `Artifacts` after the workflow is completed.

# Artifacthub

This template comes with the necessary tooling to index your image on [artifacthub.io](https://artifacthub.io). Use the `artifacthub-repo.yml` file at the root to verify yourself as the publisher. This is important to you for a few reasons:

- The value of artifacthub is it's one place for people to index their custom images, and since we depend on each other to learn, it helps grow the community. 
- You get to see your pet project listed with the other cool projects in Cloud Native.
- Since the site puts your README front and center, it's a good way to learn how to write a good README, learn some marketing, finding your audience, etc. 

[Discussion Thread](https://universal-blue.discourse.group/t/listing-your-custom-image-on-artifacthub/6446)

# Justfile Documentation

The `Justfile` contains various commands and configurations for building and managing container images and virtual machine images using Podman and other utilities. It is also used inside Github Actions.

## Required Utilities

Container build:
- [just](https://just.systems/man/en/introduction.html)
- [podman](https://docs.podman.io/en/latest)
- [jq](https://jqlang.org)

These are usually preinstalled on Universal Blue's Bootc Images.

Linting:
- shfmt
- shellcheck

## Environment Variables

These are all sourced from the `image-template.env` file.

- `image_name`: The name of the image (default: "image-template").
- `default_tag`: The default tag for the image (default: "latest").
- `bib_image`: The Bootc Image Builder (BIB) image (default: "quay.io/centos-bootc/bootc-image-builder:latest").

## Building The Image

All these recipes will work (with default values) without supplying any arguments to them, e.g. `just build`

### `just build`

Builds a container image using Podman.

```bash
just build $target_image $tag
```

Arguments:
- `$target_image`: The tag you want to apply to the image (default: `$image_name`).
- `$tag`: The tag for the image (default: `$default_tag`).

### Rechunking
We can flatten the layers of container images to make sure there isn't a single huge layer when your image gets published.
This does not make your image faster to download, just provides better resumability.

#### `just ostree-rechunk`
Rechunks the existing Image with [rpm-ostree](https://coreos.github.io/rpm-ostree/build-chunked-oci/)

```bash
just ostree-rechunk $target_image $tag
```

#### `just rechunk`
Rechunks the existing Image with [chunkah](https://github.com/coreos/chunkah), this is probably gonna be the default here at some point, try it out, it's cool.

```bash
just rechunk $target_image $tag
```

### Switching to the locally built image for testing

The image has to be in the containers-storage owned by root, to be able to rebase to it, see the `_rootful_load_image` recipe.

`sudo just build` and `sudo just ostree-rechunk` builds directly as root and allows you to skip the transfer to the root containers-storage.

You can rebase to all the images that are in your containers-storage:

```
sudo podman image list --filter=label=containers.bootc=1
```

See [man bootc switch](https://bootc.dev/bootc/man/bootc-switch.8.html) for more info.

```
sudo bootc switch --transport containers-storage localhost/myimage:latest
```

and reboot your system!

## Building and Running Virtual Machines and ISOs

The below commands all build QCOW2 images. To produce or use a different type of image, substitute in the command with that type in the place of `qcow2`. The available types are `qcow2`, `iso`, and `raw`.

### `just build-qcow2`

Builds a QCOW2 virtual machine image.

```bash
just build-qcow2 $target_image $tag
```

### `just rebuild-qcow2`

Rebuilds a QCOW2 virtual machine image.

```bash
just rebuild-vm $target_image $tag
```

### `just run-vm-qcow2`

Runs a virtual machine from a QCOW2 image.

```bash
just run-vm-qcow2 $target_image $tag
```

### `just spawn-vm`

Runs a virtual machine using systemd-vmspawn.

```bash
just spawn-vm rebuild="0" type="qcow2" ram="6G"
```

## File Management

### `just check`

Checks the syntax of all `.just` files and the `Justfile`.

### `just fix`

Fixes the syntax of all `.just` files and the `Justfile`.

### `just clean`

Cleans the repository by removing build artifacts.

### `just lint`

Runs shell check on all Bash scripts.

### `just format`

Runs shfmt on all Bash scripts.

## Additional resources

For additional driver support, ublue maintains a set of scripts and container images available at [ublue-akmod](https://github.com/ublue-os/akmods). These images include the necessary scripts to install multiple kernel drivers within the container (Nvidia, OpenRazer, Framework...). The documentation provides guidance on how to properly integrate these drivers into your container image.

## Community Examples

These are images derived from this template (or similar enough to this template). Reference them when building your image!

- [m2Giles' OS](https://github.com/m2giles/m2os)
- [bOS](https://github.com/bsherman/bos)
- [Homer](https://github.com/bketelsen/homer/)
- [Amy OS](https://github.com/astrovm/amyos)
- [VeneOS](https://github.com/Venefilyn/veneos)
