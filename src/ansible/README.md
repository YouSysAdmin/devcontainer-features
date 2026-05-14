
# Ansible (ansible)

Installs ansible-core and ansible-lint into an isolated venv at /usr/local/share/ansible-venv, with binaries symlinked into /usr/local/bin.

## Example Usage

```json
"features": {
    "ghcr.io/YouSysAdmin/devcontainer-features/ansible:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | ansible-core version to install (e.g. '2.17.5'), or 'latest'. | string | latest |
| lintVersion | ansible-lint version to install (e.g. '24.9.0'), or 'latest'. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/YouSysAdmin/devcontainer-features/blob/main/src/ansible/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
