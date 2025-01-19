# VSCode Usage

[VSCode](https://code.visualstudio.com/) provides many useful tools such as file mangement within one more many code repositories within a single workspace, source control integration with popular DevOps tools such as [GitHub](https://github.com/), terminal integration (both local and remote) to execute code, SAS Integration through a [SAS supported extension]((https://github.com/sassoftware/vscode-sas-extension)), and many other developer-friendly components.

**Table of Contents:**
- [SAS VSCode Extension](#sas-vscode-extension)
  - [Install VSCode SAS Extension](#install-vscode-sas-extension)
- [Configure SAS Extension within VSCode](#configure-sas-extension-within-vscode)
- [Configure SAS Compute Server](#configure-sas-compute-server)

## SAS VSCode Extension

The [SAS VSCode extension](https://marketplace.visualstudio.com/items?itemName=SAS.sas-lsp) provides key functionality to support SAS development.  VSCode acts as a thick client IDE that submits SAS code for execution on a remote SAS Viya server.  ODS output and the SAS log is automatically retrieved and displayed within your VSCode environment.  Output datasets are not quickly viewable within VSCode but can be analyzed using traditional SAS programming techniques.  

### Install VSCode SAS Extension

Within VSCode, go to **Extensions** from the left hand pane and search for `SAS` or use the following link to install the official SAS extension:

* [SAS VSCode extension](https://marketplace.visualstudio.com/items?itemName=SAS.sas-lsp)

## Configure SAS Extension within VSCode

The following instructions provide guidance for configuring the SAS VSCode extension.  

1. Within VSCode **Settings**, locate the SAS extension settings under the **Extensions** section on the left hand side.  Configuring at the **User** level is acceptable, but in some instances you may want to configure at the **Workspace** level if VSCode workspaces are used to organize your work per environment.
2. Populate the following Settings within **Extensions > SAS**:

```json
    "SAS.connectionProfiles": {
        "activeProfile": "XXXXXXXXXX",
        "profiles": {
            "XXXXXXXXXX": {
                "endpoint": "XXXXXXXXXX",
                "connectionType": "rest"
            }
        }
    }
```

Additional reference and answers to frequently asked questions can be found on the SAS VSCode Extension Github:

* [SAS VSCode Extension FAQ](https://sassoftware.github.io/vscode-sas-extension/faq/)

## Configure SAS Compute Server

The following instructions within this section provide steps to setup SAS as a remote execution server within your VSCode environment.

Within SAS Environment Manager, go to **Configuration**, view **Definitions**, then search for **compute**.  Select the `sas.compute.server` definition to edit.  Locate the `Compute Service: startup_commands` configuration, edit the contents and place the following line item at the bottom of the contents.  The contents should resemble a bash shell script.  This script is essentially executed for each compute session launched.  Services do not need to be restarted, changes take place immediately.

```bash
export COMPUTESERVER_LOCKDOWN_ENABLE=0
```
