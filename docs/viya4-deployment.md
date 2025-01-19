# Viya 4 Deployment Notes

The following example steps can be followed to deploy SAS Viya 4 on cloud infrastructure.  Every local deployment environment and cloud environment is different, mileage may vary.  These quick instructions were written from a Macbook Pro environment (unix command line).  Windows environments will need to establish a [linux subsystem](https://docs.microsoft.com/en-us/windows/wsl/install) prior to performing deployment steps.  The environment used to orchestrate the deployment process should be connected to the SAS VPN or physically on the SAS Campus in order to maintain connectivity with required resources.

**Table of Contents:**
- [Obtain SAS Software Order](#obtain-sas-software-order)
- [Setup SAS API Portal Token](#setup-sas-api-portal-token)
- [Setup Git Repository Within Command Line Environment](#setup-git-repository-within-command-line-environment)
- [Confirm Public viya4-deployment Repository Version](#confirm-public-viya4-deployment-repository-version)
- [Build Docker Image](#build-docker-image)
- [Establish Working Deployment Directory](#establish-working-deployment-directory)
- [Create Deployment Directory Structure WithOUT SAS Deployment Operator](#create-deployment-directory-structure-without-sas-deployment-operator)
- [Define Ansible Vars](#define-ansible-vars)
- [SSL Certificates](#ssl-certificates)
  - [Configure Viya 4 Deployment Using Ansible Vars](#configure-viya-4-deployment-using-ansible-vars)
  - [Configure Ansible Vars](#configure-ansible-vars)
- [Deploy SAS Software with Docker](#deploy-sas-software-with-docker)
  - [Key Parameters](#key-parameters)
  - [Docker Usage Notes](#docker-usage-notes)
- [Standby For Kubernetes Pods to Deploy](#standby-for-kubernetes-pods-to-deploy)
- [DNS Records](#dns-records)
- [Login with SASBOOT](#login-with-sasboot)
- [Quick Troubleshooting Steps](#quick-troubleshooting-steps)
- [Reference](#reference)

## Obtain SAS Software Order

A software order is created in partnership with a SAS Account Executive.  The software order is identified by a 6 character order number.  An important critical path requirement for deploying the software order is defining who the technical resource is that will have access to the software order and granting permission for the named individual to access the order.  The SAS Account Executive can ensure these actions are completed.

The My SAS portal is ultimately where you will see the software order and the fastest way to confirm if the technical resource can access the order for deployment.  Future software orders are listed here as well, plus other resources.  Bookmark this location.
https://my.sas.com/orders

Use the [Viya Orders portal](https://my.sas.com/orders) to determine the software cadence versions available for the specific software order.  Select the **Download** button to see what cadence versions are available.  **Long term support** versions are the most stable and least prone to errors while **Stable** release cadences provide more frequent updates and features.  Select the **"i"** icon to view more information such as [Release Notes](https://release-notes.sas.com/?locale=en) or to manually download license files.  [Release Notes](https://release-notes.sas.com/?locale=en) are very helpful to understand what changes and improvements have been made for each cadence version.  **Note: the process described below automatically downloads SAS Viya licenses through the Orders API Portal.**  Manually downloading is not necessary.

- [SAS Viya 4 My Orders Portal](https://my.sas.com/en/my-orders.html)
- [Release Notes](https://release-notes.sas.com/?locale=en)

## Setup SAS API Portal Token

Use the [Get Started Using SAS APIs](https://apiportal.sas.com/get-started) page to setup API access for this deployment process to leverage.  Access is required in order to download software binaries, license details and other data which is historically similar to the Software Depot download process.  The [Get Started Using SAS APIs](https://apiportal.sas.com/get-started) page provides steps to setup the SAS profile and register an **App**.  The **App** registered will represent the Viya 4 Deployment process, which will need access to the **SAS Viya Orders API**.

- [My Apps](https://apiportal.sas.com/my-apps)
- [New App Registration](https://apiportal.sas.com/my-apps/new-app)
- Additional technical information: [SAS Viya Orders API](https://apiportal.sas.com/docs/mysasprod/1/overview)

## Setup Git Repository Within Command Line Environment

Ensure this project is cloned within the command line execution environment. Start from a local working directory where code is managed such as within a parent development directory like `~/dev/`.

```bash
# Optional: create a place for code in the command line environment
mkdir ~/dev
cd ~/dev

# clone this repo
git clone https://github.com/Steve0verton/sas-viya4-build.git

# switch to the project directory
cd sas-viya4-build
```

## Confirm Public viya4-deployment Repository Version

Ensure the public SAS github project for `viya4-deployment` exists within [modules](./modules).  Upstream code updates from the [SAS Github](https://github.com/sassoftware) may introduce breaking changes from time to time.  Check upstream documentation for additional details.  The `init.sh` script is a useful way to reset things back to the latest public version if tweaks have been made locally.

Run Azure deployment process with **latest** code from linked git projects:
```bash
# From project repo root
./init.sh
```

## Build Docker Image

Build Docker image as described in [Docker Usage](./modules/viya4-deployment/docs/user/DockerUsage.md).  The docker image ensures all necessary components and the appropriate versions are used to deploy components successfully.

```bash
# Running from the root of the project repo
cd modules/viya4-iac-azure
docker build -t viya4-iac-azure .
```

Alternatively, rebuild all Docker images using the following utility script contained in this project repository.

```bash
# From project repo root
./build-docker-images.sh
```

## Establish Working Deployment Directory

Define an environment prefix to organize code within a working deployment directory.  This name should be unique and lasting because it will be leveraged across many aspects of deployment and ongoing administration.  Follow internal naming guidelines as appropriate.  Establish a working subdirectory within your local **deployments/** directory to organize environment configuration files and output files.  Create a directory named the exact environment prefix for consistency.  Change your working directory to to this subdirectory and work from here to build configuration files and execute the deployment process.  Establish this as your local workspace for the target environment deployed.  Be sure to create the working deployment directory within the **viya4-deployment** directory within your **deployments/** location (For example: `~/dev/deployments/viya4-deployments`).

```bash
cd ~/dev/deployments/viya4-deployments
mkdir dev2022w20
cd dev2022w20/
```

## Create Deployment Directory Structure WithOUT SAS Deployment Operator

Create customized deployment overlays within the working directory to configure things such as SSL certificates, LDAP or the sitedefault.yaml file.  The following approach does NOT use the [SAS Deployment Operator approach](https://communities.sas.com/t5/SAS-Communities-Library/Introducing-the-SAS-Viya-Deployment-Operator/ta-p/749770).  See the section below for more information on how to setup the directory structure.  An example directory structure is shown below. Also, an example viya4-deployment DAC directory structure can be found in the [SAS IAC DAC Quickstart Github repo](https://github.com/Steve0verton/sas-iac-dac-quickstart).

```bash
./deployments/viya4-deployment    <- all environment deployments are organized here
  /<environment name>             <- unique name for environment
    /<environment name + "-aks">  <- AKS cluster (Azure names with a "-aks" after environment prefix)
      /<environment name + "-ns"> <- namespace within environment
        /site-config              <- location for all customizations
          ...                     <- folders containing user defined customizations
```

For additional information regarding the SAS Deployment Operator approach, please reference the following SAS Communities post:
[Introducing the SAS Viya Deployment Operator](https://communities.sas.com/t5/SAS-Communities-Library/Introducing-the-SAS-Viya-Deployment-Operator/ta-p/749770).

## Define Ansible Vars

Define a customized deployment `ansible-vars.yaml` file within the environment working directory created above to describe the configuration of software and environment. Name the ansible-vars.yaml file specific to the environment within the environment working directory. Read through each configuration line item and this file to ensure a successful deployment. An example viya4-deployment DAC configuration can be found in the [SAS IAC DAC Quickstart Github repo](https://github.com/Steve0verton/sas-iac-dac-quickstart).

Key Components within ansible-vars.yaml file:

- `NAMESPACE` should equal the exact directory name defined within the working environment subdirectory for the environment (defined in previous step).
- `V4_DEPLOYMENT_OPERATOR_ENABLED` is used to configure the SAS Deployment Operator.  SAS Support has additional documentation on [deployment methods](https://go.documentation.sas.com/doc/en/itopscdc/v_037/itopscon/p0839p972nrx25n1dq264egtgrcq.htm?fromDefault=). [Version 6.0.0 of the viya4-deployment repository](https://github.com/sassoftware/viya4-deployment/releases/tag/6.0.0) introduced a breaking change which requires the configuration and usage of the SAS deployment operator.  
- `LOADBALANCER_SOURCE_RANGES` should be the same allowed CIDRs defined in the IAC deployment process for Azure.
- `JUMP_SVR_PRIVATE_KEY` equals the exact path of the SSH private key used to communicate with the environment.  Use the private key of the SSH pair created and used during the IAC build.
- `V4_CFG_SAS_API_KEY`,`V4_CFG_SAS_API_SECRET`,`V4_CFG_ORDER_NUMBER`,`V4_CFG_CADENCE_NAME`,`V4_CFG_CADENCE_VERSION` define API connection information and SAS order versioning to connect to the SAS Viya Orders API.  Use token key information built in previous steps.
- `V4_CFG_INGRESS_FQDN`, `V4_CFG_BASE_DOMAIN`,`V4M_BASE_DOMAIN` define the FQDN endpoint for the environment.  This is configured as a part of the Ingress in Kubernetes.

## SSL Certificates

Build SSL certificates using your internally supported method.  SSL certificates are configured in two locations, the ansible vars file and the physical location of the SSL certificate files which the ansible vars file references.

### Configure Viya 4 Deployment Using Ansible Vars

A basic SSL configuration will have a root certificate file (ending with .pem), an environment specific SSL certificate file (ending with .crt) and the private key file (ending with .key). All 3 files are required to properly configure SSL.

```bash
./deployments/viya4-deployment    <- all environment deployments are organized here at root
  /<environment name>             <- unique name for environment
    /<environment name + "-aks">  <- AKS cluster (Azure names with a "-aks" after environment prefix)
      /<environment name + "-ns"> <- namespace within environment (contains license tgz)
        /site-config              <- location for all customizations
          /security               <- location for SSL certificates
            /cacerts              <- location for SSL PEM file
              /XXXXXX.pem         <- Root SSL Certificate Authority file
            {{BASE_DOMAIN}}.crt   <- Environment certificate file
            {{BASE_DOMAIN}}.key   <- Environment private key
```

### Configure Ansible Vars

Ensure the following lines are configured within the **ansible.vars.yaml** file created in a previous step. The `/data` path is the starting mountpoint the Docker container references in the next step.

```bash
# TLS
V4_CFG_TLS_GENERATOR: openssl
V4_CFG_TLS_MODE: "front-door" # [full-stack|front-door|disabled]
V4_CFG_TLS_CERT: /data/{{ENVIRONMENT_NAME}}-aks/{{ENVIRONMENT_NAME}}-ns/site-config/cacerts/{{BASE_DOMAIN}}.crt
V4_CFG_TLS_KEY: /data/{{ENVIRONMENT_NAME}}-aks/{{ENVIRONMENT_NAME}}-ns/cacerts/{{BASE_DOMAIN}}.key
V4_CFG_TLS_TRUSTED_CA_CERTS: /data/{{ENVIRONMENT_NAME}}-aks/{{ENVIRONMENT_NAME}}-ns/cacerts
```

## Deploy SAS Software with Docker

Run Docker commands to deploy SAS Viya Software. Run one of the following Docker commands to deploy the software depending on the approach required.  Additional usage notes can be found in the [Docker Usage](./modules/viya4-deployment/docs/user/DockerUsage.md) documentation.  Ensure your command line environment still has an active connection to Azure prior to running by executing `az account show`.

Deploy only Viya and necessary components for a standard SAS Viya environment:

```bash
docker run --rm \
  --group-add root \
  --user $(id -u):$(id -g) \
  --volume $(pwd):/data \
  --volume $HOME/dev/deployments/viya4-iac-azure/{{ENVIRONMENT_NAME}}/{{ENVIRONMENT_NAME}}-aks-kubeconfig.conf:/config/kubeconfig \
  --volume $HOME/dev/deployments/viya4-deployment/{{ENVIRONMENT_NAME}}/{{ENVIRONMENT_NAME}}.yaml:/config/config \
  --volume $HOME/dev/deployments/viya4-iac-azure/{{ENVIRONMENT_NAME}}/terraform.tfstate:/config/tfstate \
  --volume $HOME/.ssh/azure:/config/jump_svr_private_key \
  viya4-deployment --tags "baseline,viya,install" -vvv &> deploy.log
```

Deploy all components for SAS Viya and advanced monitoring and logging tools:

```bash
docker run --rm \
  --group-add root \
  --user $(id -u):$(id -g) \
  --volume $(pwd):/data \
  --volume $HOME/dev/deployments/viya4-iac-azure/{{ENVIRONMENT_NAME}}/{{ENVIRONMENT_NAME}}-aks-kubeconfig.conf:/config/kubeconfig \
  --volume $HOME/dev/deployments/viya4-deployment/{{ENVIRONMENT_NAME}}/{{ENVIRONMENT_NAME}}.yaml:/config/config \
  --volume $HOME/dev/deployments/viya4-iac-azure/{{ENVIRONMENT_NAME}}/terraform.tfstate:/config/tfstate \
  --volume $HOME/.ssh/azure:/config/jump_svr_private_key \
  viya4-deployment --tags "baseline,viya,cluster-logging,cluster-monitoring,viya-monitoring,install" -vvv &> deploy.log
```

### Key Parameters

- `--volume $(pwd):/data` maps the current working directory to the Docker image.  Run this docker command within the environment-specific working directory created in the previous step.
- `--volume $HOME/dev/deployments/viya4-iac-azure/{{ENVIRONMENT_NAME}}/{{ENVIRONMENT_NAME}}-aks-kubeconfig.conf:/config/kubeconfig` should point directly to the Kubernetes configuration file output from the IAC build.
- `--volume $HOME/dev/deployments/viya4-deployment/{{ENVIRONMENT_NAME}}/{{ENVIRONMENT_NAME}}.yaml:/config/config` should point to the name of the **ansible-vars** file defined in previous steps.
- `--volume $HOME/dev/deployments/viya4-iac-azure/{{ENVIRONMENT_NAME}}/terraform.tfstate:/config/tfstate` should point to the Terraform output file from the IAC build.  This tells the deployment process where and how to connect to the environment.
- `--volume $HOME/.ssh/azure:/config/jump_svr_private_key` should point to the SSH private key used in the initial IaC build.
- `--tags` defines the [tasks](https://github.com/sassoftware/viya4-deployment/blob/main/docs/user/DockerUsage.md#tasks) to perform.  Further information can be found on the [SAS Github DockerUsage.md](https://github.com/sassoftware/viya4-deployment/blob/main/docs/user/DockerUsage.md#examples) documentation.

### Docker Usage Notes

Docker `--volume` mount point parameters map local environment directory paths (contained on your laptop) to directories contained internally to the Docker image.  The colon symbol is used to link source and target volume mount points.  Pay close attention when editing these volume mappings to ensure directory paths are accurately represented and the colon symbol exists.  Docker only supports absolute directory paths, not relative; but does support environment variables such as `$HOME`.

Additional docker volume mappings can be found in the public [SAS Github repository DockerVolumeMounts.md](https://github.com/sassoftware/viya4-deployment/blob/main/docs/user/DockerVolumeMounts.md) documentation.

## Standby For Kubernetes Pods to Deploy

**WAIT 1-2 HOURS FOR SOFTWARE DEPLOYMENT TO FINISH.** Ansible will appear to complete but most of the work is still occurring on the Kubernetes cluster.  Use Lens to monitor the status of the **pods** on the cluster and check for any errors.  All pods should be green, with no errors or anything in pending status.

## DNS Records

Register the environment with appropriate DNS records within your corporate environment. Retrieve the public facing IP address of the environment through a Kubernetes tool such as Lens.  The public facing IP address can be found in Lens under `Network > Ingresses`.  Find the IP address under the LoadBalancers column for the namespace of this deployment.

## Login with SASBOOT

Log in with `sasboot` for full administrative capabilities.  The default password is configured in the **sitedefault.yaml** file within the `site-config` subdirectory.

## Quick Troubleshooting Steps

- Destroy and rebuild Docker images to ensure orchestration tools and software packages do not have updates that downstream SAS processes depend on.
- Ensure deploy working directory is cleaned up on major configuration changes.
- Chrome will not allow access to the web applications if SSL is not working. Type in `thisisunsafe` when Chrome complains and the environment will be added to an allow list.

## Reference

- [Public vs Private SSH Keys](https://winscp.net/eng/docs/ssh_keys)
