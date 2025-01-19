# Azure Deployment Notes

The following example steps can be followed to deploy virtual resources with Azure.  Every local environment and cloud environment is different, mileage may vary.  Windows environments will need to establish a [linux subsystem](https://docs.microsoft.com/en-us/windows/wsl/install) prior to performing deployment steps.  Network topology considerations are very important for deploying and managing resources within the cloud.  Ensure firewall and other security measures allow orchestration to occur between local environment(s) and cloud assets.

**Table of Contents:**
- [Setup Git Repository Within Command Line Environment](#setup-git-repository-within-command-line-environment)
- [Confirm Public viya4-iac-azure Repository Version](#confirm-public-viya4-iac-azure-repository-version)
- [Confirm Azure CLI Connection](#confirm-azure-cli-connection)
- [Generate SSH Key Pair](#generate-ssh-key-pair)
- [Configure Azure Service Principal](#configure-azure-service-principal)
  - [Key Outputs](#key-outputs)
  - [Troubleshooting Tips](#troubleshooting-tips)
- [Build Docker Image](#build-docker-image)
- [Establish Working Deployment Directory](#establish-working-deployment-directory)
- [Configure Infrastructure with Terraform](#configure-infrastructure-with-terraform)
  - [Key Components](#key-components)
  - [Confirm Latest Version of Kubernetes Supported by Azure AKS](#confirm-latest-version-of-kubernetes-supported-by-azure-aks)
- [Test Configuration in Plan Mode](#test-configuration-in-plan-mode)
  - [Docker IAC Plan Key Parameters](#docker-iac-plan-key-parameters)
  - [Troubleshooting Considerations](#troubleshooting-considerations)
  - [Docker Usage Notes](#docker-usage-notes)
- [Ensure Network Connectivity to Azure Cloud Subscription](#ensure-network-connectivity-to-azure-cloud-subscription)
  - [Confirm External Facing IP Address](#confirm-external-facing-ip-address)
- [Execute Docker Container to Build Cloud Infrastructure](#execute-docker-container-to-build-cloud-infrastructure)
  - [Docker IAC Build Key Parameters](#docker-iac-build-key-parameters)
  - [Docker IAC Build Key Outputs](#docker-iac-build-key-outputs)
- [Finalize Deployment](#finalize-deployment)
  - [Check Kubeconfig File](#check-kubeconfig-file)
- [Troubleshooting](#troubleshooting)
- [Reference](#reference)

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

## Confirm Public viya4-iac-azure Repository Version

Ensure the public SAS github project for `viya4-iac-azure` exists within [modules](./modules).  Upstream code updates from the [SAS Github](https://github.com/sassoftware) may introduce breaking changes from time to time.  Check upstream documentation for additional details.  The `init.sh` script is a useful way to reset things back to the latest public version if tweaks have been made locally.

Run Azure deployment process with **latest** code from linked git projects:

```bash
# From project repo root
./init.sh
```

## Confirm Azure CLI Connection

Ensure your local environment can authenticate to your Microsoft Azure subscription. The [Azure CLI needs to be installed](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) to the command line interface leveraged during this process, which for Windows will be the Windows Subsystem for Linux (WSL).

- Configure Azure CLI: `az login`
- Confirm access and environment configuration: `az account show`
- Ensure a single subscription is set to default: `az account set --subscription {{YOUR_ID}}`

There can be multiple subscriptions assigned to your account.  If there are multiple subscriptions associated with your account, the `az account show` command will list multiple results. Ensure the correct subscription is set to default.

## Generate SSH Key Pair

Generate an SSH key pair within your command line interface leveraged during this process to communicate with Azure or ensure one is defined within your environment.  The public key file is sent to Azure to enable passwordless authentication.  [Google](https://google.com) can help provide many ways to accomplish this.  Example code provided below creates a public/private key pair within `.ssh` within your home directory.  **Do not create a passphrase during the SSH keygen process.**

```bash
# Generate key pair
ssh-keygen -t rsa -f ~/.ssh/azure
```

**NOTE:** Do not enter a passphrase when prompted during the keygen process.  Ensure the private key file (without the .pub extension) is secured with `chmod 400` permissions.

## Configure Azure Service Principal

Configure Azure service principal for [Terraform authentication](https://github.com/sassoftware/viya4-iac-azure/blob/main/docs/user/TerraformAzureAuthentication.md) using the following shell script provided in [utilities](./utilities).  The purpose of this Azure Service Principal is to act as a service account that performs the operations within Azure using the Terraform process provided by the [SAS viya4-iac-azure](https://github.com/sassoftware/viya4-iac-azure) repo.

```bash
# Running from the root of the project repo
cd utilities
# Generate tokens
./generate-azure-service-principal.sh
# move environment file to secure location like home directory (this will be referenced later)
mv .azure_docker_creds.env ~/
chmod 700 ~/.azure_docker_creds.env
```

A list of service principals created can be found within the Azure management console within **App registrations**.

### Key Outputs

The `.azure_docker_creds.env` file should contain 4 lines representing 4 variables that each have a single value.  Each value will appear as a random hash code. An example of this is shown below.  

```bash
more ~/.azure_docker_creds.env
TF_VAR_subscription_id=i1hr3q32drhadn903
TF_VAR_tenant_id=90e23e8hwlqiohdp9283
TF_VAR_client_id=oquejp23-oksfsad90uf-elhq2h3le
TF_VAR_client_secret=sdf902j3as!diau~dykahoih
```

### Troubleshooting Tips

If this shell script has problems or errors, try running again.  Use the [App Registrations](https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade) section within Azure to delete any prior obsolete service principals created in error.  Because this shell script process is custom, if problems arise that do not resolve themself, run each `az` command within the shell script individually to attempt to diagnose the problem further.

## Build Docker Image

Build Docker image used for deploying the Azure infrastructure as described in [Docker Usage](./modules/viya4-iac-azure/docs/user/DockerUsage.md). The docker image ensures all necessary components and the appropriate versions are used to deploy components successfully.

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

Define an environment prefix to organize code within a working deployment directory.  This name should be unique and lasting because it will be leveraged across many aspects of deployment and ongoing administration.  Follow internal naming guidelines as appropriate.  Establish a working subdirectory within your local **deployments/** directory to organize environment configuration files and output files.  Create a directory named the exact environment prefix for consistency.  Change your working directory to to this subdirectory and work from here to build configuration files and execute the deployment process.  Establish this as your local workspace for the target environment deployed.  Be sure to create the working deployment directory within the **viya4-iac-azure** directory within your **deployments/** location (For example: `~/dev/deployments/viya4-iac-azure`).  The `viya4-iac-azure` subdirectory establishes a middle abstraction layer to organize [Infrastructure-as-code (IAC)](https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code), i.e. `viya4-iac-azure`; versus Deployment-as-code (DAC), i.e. `viya4-deployment`.

```bash
cd ~/dev/deployments/viya4-iac-azure
mkdir dev2022w20
cd dev2022w20/
```

## Configure Infrastructure with Terraform

Configure the infrastructure to be deployed using a **tfvars** file and store this file within the subdirectory created for the target environment.  Leverage the [SAS IAC DAC Quickstart Github repo](https://github.com/Steve0verton/sas-iac-dac-quickstart) for examples to follow for building the **tfvars** file.  Make appropriate changes to any of the starter example tfvars files to meet your system requirements.

The public [SAS Github](https://github.com/sassoftware) has excellent documentation on each variable which can be set within the **tfvars** file: [https://github.com/sassoftware/viya4-iac-azure/blob/main/docs/CONFIG-VARS.md](https://github.com/sassoftware/viya4-iac-azure/blob/main/docs/CONFIG-VARS.md).  The public [SAS Github](https://github.com/sassoftware) also contains additional [example tfvars files](https://github.com/sassoftware/viya4-iac-azure/tree/main/examples) to follow.

### Key Components

- `prefix` should represent a unique identifier of the environment you wish to build. Configuration files and output files in this process use this to name files as well as the actual environment in Azure.  All resources are automatically grouped into a single resource group identified by the `prefix` value.
- `ssh_public_key` points to your local SSH public key generated previously. Specify the public key (not the private).  
- `subscription_id` equals the `id` variable output from running the command `az account show`.
- `tenant_id` equals the `tenantId` variable output from running the command `az account show`.
- `kubernetes_version` defines the version of kubernetes (k8s) for the AKS cluster.
- `default_nodepool_min_nodes` defines the minimum number of nodes which should be powered up and running within a node pool. **Recommendation:** set to at least 1 for initial deployment then scale back to 0 afterwards. The initial deployment can consume a lot of resources up front, therefore having plenty of hardware resources already spun up reduces the chance of error during the deployment process. Similarly, the `min_nodes` within each node pool definition can be configured as well and should be set to at least 1.
- `cluster_node_pool_mode` sets the operating mode of clustered services to act minimally or in a clustered mode.  Setting this to `minimal` is ideal for demo or POC environments.  Compute resources do not run until an end user uses SAS.
- `default_public_access_cidrs` must contain CIDRs which the public facing IP of your local environment is contained within in order to connect to the Azure environment being deployed.  Terraform automatically creates firewall rules in Azure to allow access.  Assume a "least privileges approach" such that only specified IP CIDRs can access the target environment.  This ensures a simple and effective way to secure the environment, but also requires a clear understanding of network topology to ensure the environment can be accessed.
- `cluster_endpoint_public_access_cidrs` must also contain CIDRs which the public facing IP of your local environment is contained within in order to connect to the Azure environment being deployed. This variable defines firewall rules for the Kubernetes cluster API endpoint.
- `vm_public_access_cidrs` must also contain CIDRs which the public facing IP of your local environment is contained within in order to connect to the Azure environment being deployed. This variable defines the firewall rules for the jumpbox created within the resource group.

### Confirm Latest Version of Kubernetes Supported by Azure AKS

Use the following command to output a list of supported version for Kubernetes running within the AKS cluster.  Align the latest version of [kubernetes supported with the version of SAS Viya 4](https://documentation.sas.com/doc/ru/itopscdc/v_059/itopssr/n1ika6zxghgsoqn1mq4bck9dx695.htm) you intend to deploy.

```bash
az aks get-versions --location eastus --output table
```

Reference: [SAS Support: Virtual Infrastructure Requirements](https://documentation.sas.com/doc/ru/itopscdc/v_059/itopssr/n1ika6zxghgsoqn1mq4bck9dx695.htm#p0nir72r7wvm6sn1wsxpkup0zso7)

## Test Configuration in Plan Mode

Run the following Docker command to confirm everything is working as expected.  Be sure to run this command from within the working subdirectory created previously.  

```bash
docker run --rm --group-add root \
  --user "$(id -u):$(id -g)" \
  --env-file=$HOME/.azure_docker_creds.env \
  --volume=$HOME/.ssh:/.ssh \
  --volume=$(pwd):/workspace \
  viya4-iac-azure \
  plan \
    -var-file=/workspace/{{ENVIRONMENT_NAME}}.tfvars \
    -state=/workspace/terraform.tfstate
```

### Docker IAC Plan Key Parameters

- `--env-file=$HOME/.azure_docker_creds.env` defines the Service Principal credentials generated previously.  Ensure this file maps appropriately on your local environment. This file was generated previously and should contain 4 lines representing 4 variable definitions.
- `--volume=$HOME/.ssh:/.ssh` maps the SSH keys used during this process.  This volume map must point to the directory where SSH keys are stored on your local environment.  The **tfvars** configuration file will reference the exact SSH public key.
- `--volume=$(pwd):/workspace` maps the current working directory to the Docker image.  Run this docker command within the environment-specific working directory created in the previous step.
- `viya4-iac-azure` references the Docker image tag generated previously.
- The `plan` command tells Terraform to just plan what changes are to be made but do not apply or deploy anything.
- `-var-file=/workspace/{{ENVIRONMENT_NAME}}.tfvars` maps the **tfvars** file defined previously which will be used to build the infrastructure.
- `-state=/workspace/terraform.tfstate` defines the Terraform state file which is generated after building the infrastructure in Azure.

The `-var-file` and `-state` parameters are specific to the Terraform command run within the Docker container.

### Troubleshooting Considerations

If a prior IAC deployment has been executed in plan mode or apply mode, make sure the `terraform.tfstate` and `terraform.tfstate.backup` files **do NOT exist when running this command again**.  Delete the `terraform.tfstate` and `terraform.tfstate.backup` files and rerun the Docker command above.  Prior tfstate files can break things.

### Docker Usage Notes

Docker `--volume` mount point parameters map local environment directory paths (contained on your laptop) to directories contained internally to the Docker image.  The colon symbol is used to link source and target volume mount points.  Pay close attention when editing these volume mappings to ensure directory paths are accurately represented and the colon symbol exists.  Docker only supports absolute directory paths, not relative; but does support environment variables such as `$HOME`.

This command should product a large output of the actual changes Terraform will make if you were to actually run the process in **apply** mode.  Look for **errors** and **warnings**.

## Ensure Network Connectivity to Azure Cloud Subscription

Ensure you are connected to the proper network based on the network topology your environment configuration assumes.  Your public facing IP address must be in the allowed IP ranges described in previous steps above. Often times corporate VPN clients have a "Direct" option which tunnels all traffic to your corporate network. This may be a common solution to ensure the appropriate network configuration when working remotely.

### Confirm External Facing IP Address

Use the website [https://whatismyipaddress.com/](https://whatismyipaddress.com/) to confirm your public facing IP address is within configured CIDR.

Use the following command to confirm the IP address as seen from the external internet (i.e. Azure cloud).  This is helpful confirming if the command line execution environment has the proper IP address within your current network topology.

```bash
curl ipinfo.io/ip
```

## Execute Docker Container to Build Cloud Infrastructure

Run the following Docker command to deploy the infrastructure. Run this from within the working directory established in previous steps. Ensure your command line environment still has an active connection to Azure prior to running by executing `az account show`.

```bash
docker run --rm --group-add root \
  --user "$(id -u):$(id -g)" \
  --env-file=$HOME/.azure_docker_creds.env \
  --volume=$HOME/.ssh:/.ssh \
  --volume=$(pwd):/workspace \
  viya4-iac-azure \
  apply -auto-approve \
    -var-file=/workspace/{{ENVIRONMENT_NAME}}.tfvars \
    -state=/workspace/terraform.tfstate
```

### Docker IAC Build Key Parameters

- `--env-file=$HOME/.azure_docker_creds.env` defines the Service Principal credentials generated previously.  Ensure this file maps appropriately on your local environment. This file was generated previously and should contain 4 lines representing 4 variable definitions.
- `--volume=$HOME/.ssh:/.ssh` maps the SSH keys used during this process.  This volume map must point to the directory where SSH keys are stored on your local environment.  The **tfvars** configuration file will reference the exact SSH public key.
- `--volume=$(pwd):/workspace` maps the current working directory to the Docker image.  Run this docker command within the environment-specific working directory created in the previous step.
- `viya4-iac-azure` references the Docker image tag generated previously.
- The `apply -auto-approve` command tells Terraform to deploy everything and automatically approve.
- `-var-file=/workspace/{{ENVIRONMENT_NAME}}.tfvars` maps the **tfvars** file defined previously which will be used to build the infrastructure.
- `-state=/workspace/terraform.tfstate` defines the Terraform state file which is generated after building the infrastructure in Azure.

The `-var-file` and `-state` parameters are specific to the Terraform command run within the Docker container.

### Docker IAC Build Key Outputs

If the deployment process is successful you should see an output of important environment connection information.  You can always run the command `terraform output` from within the working environment directory to output this same connection information again.  The `terraform output` command uses the **terraform.tfstate** file stored after a successful deployment in Step 11 above.

If the deployment process fails there should be output on the command line which stops where the error occurred.

The following files are critical outputs of the deployment process.

- `terraform.tfstate`
  - **This file needs to be deleted if running the same build commands from above to redeploy the same environment.  Terraform has problems if this file exists for the same target environment configuration.**
- `{{ENVIRONMENT_NAME}}-aks-kubeconfig.conf`
  - This file contains connection credentials to connect your preferred Kubernetes tool such as [Lens](https://k8slens.dev/).

## Finalize Deployment

### Check Kubeconfig File

Ensure the kubectl configuration file is secured after IAC deployment is complete.  This file is in plain-text and contains sensitive connection info to the kubernetes ecosystem.  **Secure this file**

```bash
# From within the working deployment directory (i.e. ~/dev/deployments/viya4-iac-azure/{{ENVIRONMENT_NAME}})
chmod 700 {{ENVIRONMENT_NAME}}-aks-kubeconfig.conf
```

Confirm kubeconfig file contains certificate information populated.  Sometimes this encoded string is not provided.  If the kubeconfig file appears corrupt, use the following command to regenerate using the Azure command line interface.

```bash
az aks get-credentials --resource-group {{ENVIRONMENT_NAME}}-rg --name {{ENVIRONMENT_NAME}}-aks --file {{ENVIRONMENT_NAME}}-aks-kubeconfig.conf
```

## Troubleshooting

Azure resources are organized by **resource group**.  Entire resource groups can be destroyed quickly in the event of failed deployments.  Terraform can also destory infrastructure from the command line.

Often times, network topology can create indirect issues.  If timeout errors occur, try ensuring your laptop only has 1 network interface active to ensure the VPN connectivity is correct and your laptop only has 1 external facing IP address.  For example, having a hardwire network cable connection plus a WiFi connection can create issues.

## Reference

- [Public vs Private SSH Keys](https://winscp.net/eng/docs/ssh_keys)
