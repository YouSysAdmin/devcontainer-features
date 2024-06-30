
# Node.js (via nvm), yarn and pnpm (node)

Installs Node.js, nvm, yarn, pnpm, and needed dependencies.

## Example Usage

```json
"features": {
    "ghcr.io/YouSysAdmin/devcontainer-features/node:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a Node.js version to install | string | lts |
| nodeGypDependencies | Install dependencies to compile native node modules (node-gyp)? | boolean | true |
| nvmInstallPath | The path where NVM will be installed. | string | /usr/local/share/nvm |
| nvmVersion | Version of NVM to install. | string | latest |
| installYarnUsingApt | On Debian and Ubuntu systems, you have the option to install Yarn globally via APT. If you choose not to use this option, Yarn will be set up using Corepack instead. This choice is specific to Debian and Ubuntu; for other Linux distributions, Yarn is always installed using Corepack, with a fallback to installation via NPM if an error occurs. | boolean | true |

## Customizations

### VS Code Extensions

- `dbaeumer.vscode-eslint`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/YouSysAdmin/devcontainer-features/blob/main/src/node/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
