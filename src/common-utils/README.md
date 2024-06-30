
# Common Utilities (common-utils)

Installs a set of common command line utilities, Oh My Zsh!, and sets up a non-root user.

## Example Usage

```json
"features": {
    "ghcr.io/YouSysAdmin/devcontainer-features/common-utils:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installZsh | Install ZSH? | boolean | true |
| configureZshAsDefaultShell | Change default shell to ZSH? | boolean | true |
| installOhMyZsh | Install Oh My Zsh!? | boolean | true |
| installOhMyZshConfig | Allow installing the default dev container .zshrc templates? | boolean | true |
| upgradePackages | Upgrade OS packages? | boolean | true |
| username | Enter name of a non-root user to configure or none to skip | string | dev |
| userUid | Enter UID for non-root user | string | automatic |
| userGid | Enter GID for non-root user | string | automatic |
| nonFreePackages | Add packages from non-free Debian repository? (Debian only) | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/YouSysAdmin/devcontainer-features/blob/main/src/common-utils/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
