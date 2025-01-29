# SAS Viya 4 Build

Collection of content to enable SAS Viya 4 deployments in the cloud.  This project provides an umbrella-style collection of content which links to other public git repositories; as well as tools and additional instruction intended to provide a comprehensive approach to deploy a Viya 4 environment end to end.  This project is primarily designed for Microsoft Azure.  The public [SAS Github](https://github.com/sassoftware) is used for for cloud infrastructure (IAC) and the Viya 4 software deployment (DAC) processes.  Additional documentation is indexed and highlighted in the [SAS Github Documentation](#sas-public-github-documentation) below and recommended for additional reading.  **Every IT ecosystem is different - mileage may vary.**

Viya 4 leverages a code-first mindset for architecture, deployment and ongoing administration.  Everything is deployed with code and command line processes, making this project git repository and dependent git repositories very important to understand.  Designing, developing and deploying cloud infrastructure and SAS software with a code-first mindset has a steep learning curve but well worth the time and effort in the long run because of the extremely scalable capability of rapid deployments over time using code, as well as increased visibility into exact steps performed during deployments because everything is managed via code.  Version control systems such as Github provide excellent ways to manage centrally and provide historical reference to prior versions.

For questions or support, create an Issue here in Github.

**Table of Contents:**
- [Key Dependencies](#key-dependencies)
- [Project Directory Structure](#project-directory-structure)
- [General Required Knowledge](#general-required-knowledge)
- [Getting Started](#getting-started)
- [Define Environment Naming Prefix](#define-environment-naming-prefix)
- [Environment Configuration Code Organization](#environment-configuration-code-organization)
  - [Managing Environment IAC/DAC Deployment Configurations](#managing-environment-iacdac-deployment-configurations)
  - [Define Deployment Directories for Environment](#define-deployment-directories-for-environment)
    - [Create Environment-Specific Configuration Directories from Scratch](#create-environment-specific-configuration-directories-from-scratch)
    - [Replicating an Environment](#replicating-an-environment)
- [Key Configuration Files](#key-configuration-files)
- [Troubleshooting Considerations](#troubleshooting-considerations)
  - [Confirm External Facing IP Address](#confirm-external-facing-ip-address)
- [Reference](#reference)
  - [SAS Public Github Documentation](#sas-public-github-documentation)
  - [Azure Kubernetes Version Matrix](#azure-kubernetes-version-matrix)


## Key Dependencies

The following list highlights critical upstream dependencies of this project repository.

* [Github viya4-iac-azure Repo](https://github.com/sassoftware/viya4-iac-azure)
  * Public Github repository for generally available IAC code for Viya 4 infrastructure builds on Microsoft Azure.
* [Github viya4-deployment Repo](https://github.com/sassoftware/viya4-deployment)
  * Public Github repository for generally available DAC code for Viya 4 software deployments.

## Project Directory Structure

* [docs](./docs) - Documentation for specific areas such as infrastructure, software and other useful administrative tasks
* **modules** - Base code repositories initialized by the [init.sh](./init.sh) script.
  * [/viya4-iac-azure](https://github.com/sassoftware/viya4-iac-azure) - Linked to [public SAS IAC Github](https://github.com/sassoftware/viya4-iac-azure)
  * [/viya4-deployment](https://github.com/sassoftware/viya4-deployment) - Linked to [public SAS DAC Github](https://github.com/sassoftware/viya4-deployment)
  * **{{LINKED REPO}}** - Organize additional externally linked project repositories here
* [utilities](./utilities) - Custom built tools to perform operational tasks within this repository

## General Required Knowledge

The following tools and technology are leveraged to deploy SAS Viya 4 in the cloud.  At the minimum, a general understanding is recommended to ensure success.

* [Docker](https://www.docker.com/)
* [Terraform](https://www.terraform.io/intro/index.html)
* [Git](https://git-scm.com/doc)
* Cloud Technology Provider (Azure, AWS, GCP, etc)
  - [Microsoft Azure Cloud](https://azure.microsoft.com/)
* Command Line Interface
  * Windows Subsystem for Linux (Windows Users)
  * Unix (MacOS)
  * Linux (RHEL or Ubuntu)
* [Kubernetes](https://kubernetes.io/docs/concepts/)

## Getting Started

The following instructions outline steps to deploy Viya 4.  Each step may link to more detailed documentation contained within the [docs](./docs) directory.

1. Initial setup of computer used for deployment process (i.e. your laptop): [docs/initial-setup.md](./docs/initial-setup.md)
2. Ensure this project repository is cloned to your local environment used to orchestrate the deployment process. The root path of `~/dev` used in this example can be set to any path as needed - this is only an example.
    ```bash
    # Establish a place for code
    mkdir -p ~/dev
    cd ~/dev

    # clone this repo into a place to manage code locally (i.e. ~/dev)
    git clone https://github.com/Steve0verton/sas-viya4-build.git

    # move to the project directory
    cd sas-viya4-build
    ```
3. Clone dependent repositories for IAC and DAC configuration from SAS Github:
    ```bash
    # From this project repo root
    ./init.sh
    ```
4. [Determine an environment prefix name](#define-environment-naming-prefix) which will be referenced by directory structures, IAC and DAC code. This prefix name is important because it perpetuates throughout everything.
    * Example: `dev-2022w20`
5. Organize code and setup environment-specific deployment code directories to work from. Example steps are [provided below](#code-organization).
   * **Tip:** Build internal git repositories to manage environment-specific code.
6. Deploy Azure Cloud Infrastructure: [docs/azure-deployment.md](./docs/azure-deployment.md). Work from environment-specific deployment directory.
7. Deploy SAS Viya 4 Software: [docs/viya4-deployment.md](./docs/viya4-deployment.md). Work from environment-specific deployment directory.
8. Ongoing Administration:
   * Using Kubernetes: [docs/kubernetes.md](./docs/kubernetes.md)

## Define Environment Naming Prefix

Environments are identified by a unique prefix or mnemonic name such as `dev-2022w20`.  **It is important to define a unique name** for referencing code, directories, filenames and the environment itself.  This mnemonic name is assimilated in many places during and after the deployment. This prefix name could be something that focuses on the purpose of the environment or follows organizational naming standard.

## Environment Configuration Code Organization

Code used to deploy specific environments is maintained in a separate directory managed **separately from this git project repository.**  Code within **this** project repository is used to document and guide the code and configuration within the environment-specific deployment directories.  Environment-specific deployment code is conceptually grouped by [Infrastructure-as-code (IAC)](https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code) or [Deployment-as-code (DAC)](https://octopus.com/docs/deployments/patterns/deployment-process-as-code). IAC builds the cloud infrastructure used to run Viya 4 while DAC deploys the software components and relevant configuration of SAS Viya software.  Organizing deployments is useful for leveraging prior success for future environment builds by memorializing environment configuration, code, dependencies and deployment process files.  

### Managing Environment IAC/DAC Deployment Configurations

A **deployments** directory is useful for organizing environment-specific IAC/DAC code.  This directory can be named anything, **deployments** is only an example.

```bash
# Establish a place for git repositories which manages environment-specific configuration code
mkdir -p ~/dev/deployments
cd ~/dev/deployments
git clone {{YOUR_IAC_CONFIG_REPO}}
git clone {{YOUR_DAC_CONFIG_REPO}}
```

Environment-specific git repositories should be setup within the `deployments` directory created.  Configuration code is best managed through git to ensure version control and provide a mechanism for collaboration. Setup git repositories within your own corporate ecosystem and follow necessary guidelines for managing your own git repositories.  A single git repository could be created to manage all environment-specific code, or separate git repositories can be used to manage IAC versus DAC code separately based on internal security requirements.  

### Define Deployment Directories for Environment

Decide where to source the initial configuration from.  Either build from scratch or copy an existing environment to build from.  

#### Create Environment-Specific Configuration Directories from Scratch

```bash
# Create directories for a specific environment
mkdir -p ~/dev/deployments/viya4-iac-azure/dev-2022w20
mkdir -p ~/dev/deployments/viya4-deployment/dev-2022w20
```

#### Replicating an Environment

These instructions provide an approach of replicating an existing working environment within a deployment area located within `~/dev/deployments` (as described above in a previous section).  

Replicate IAC code to build new infrastructure in Azure.

```bash
# Navigate to where deployment code is maintained
cd ~/dev/deployments/viya4-iac-azure
cp -R dev-2022w20 dev-2022w27
```

Replicate software deployment code to manage a new environment.

```bash
# Navigate to where deployment code is maintained
cd ~/dev/deployments/viya4-deployment
cp -R dev-2022w20 dev-2022w27
```

## Key Configuration Files

The following list summarizes critical files and directories for configuring Viya 4 deployments.  Additional files will exist for more advanced functionality. The root path of `~/dev` used in this example can be any path specific to your local environment - this is only an example.

* `~/dev/deployments/`
  * `viya4-iac-azure/{{ENVIRONMENT_PREFIX}}/`
    * `{{ENVIRONMENT_PREFIX}}.tfvars`
  * `viya4-deployment/{{ENVIRONMENT_PREFIX}}/`
    * `{{ENVIRONMENT_PREFIX}}-aks/{{ENVIRONMENT_PREFIX}}-ns/site-config/`
      * `security/`
        * `cacerts/{{ROOT_CA}}.pem`
        * `{{SUBDOMAIN}}.crt`
        * `{{SUBDOMAIN}}.key`
      * `openldap-modify-users.yaml`
      * `sitedefault.yaml`
    * `{{ENVIRONMENT_PREFIX}}.yaml`

## Troubleshooting Considerations

Troubleshooting problems can be challenging in Viya 4.  Sometimes network topology related errors messages can be challenging due to complex network connectivity from your laptop to the target Azure environment.  For example, network connectivity flows from within a Windows Subsystem for Linux container locally, to your laptop's network adaptor, to a corporate VPN client installed on your laptop.  Sometimes complex configurations locally (before the VPN client) can create confusion.  Outside of your laptop, complicated internet connectivity can also create problems randomly such as home WiFi problems or Internet Service Provider connectivity issues.

### Confirm External Facing IP Address

Use the following command as a troubleshooting step to confirm the IP address as seen from the external internet (i.e. Azure cloud).  This is helpful confirming if the command line execution environment has the proper IP address within your current network topology.

```bash
curl ipinfo.io/ip
```

## Reference

### SAS Public Github Documentation

The following documentation is helpful to read through and understand as a part of the public SAS Github.

- [Viya 4 IAC for Azure README](https://github.com/sassoftware/viya4-iac-azure/blob/main/README.md)
- [Viya 4 Terraform Configuration Variables](https://github.com/sassoftware/viya4-iac-azure/blob/main/docs/CONFIG-VARS.md)
- [Viya 4 Deployment README](https://github.com/sassoftware/viya4-deployment/blob/main/README.md)
- [Viya 4 Deployment Ansible Vars](https://github.com/sassoftware/viya4-deployment/blob/main/docs/CONFIG-VARS.md)

### Azure Kubernetes Version Matrix

The following link provides information regarding the Kubernetes versions supported by Azure.  Versions provided in configuration files must include [major].[minor].[patch] naming semantics (include all 3 numbers).  Configuration files may include the **tfvars** file for building cloud infrastructure or other processes which interact with Kubernetes.

- [https://github.com/kubernetes-sigs/cloud-provider-azure#version-matrix](https://github.com/kubernetes-sigs/cloud-provider-azure#version-matrix)
