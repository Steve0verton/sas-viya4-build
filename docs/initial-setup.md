# Initial Setup

The following steps are intended to help setup the machine leveraged for the deployment process (i.e. your laptop).  Ensure each step is followed repsective to the operating system on your laptop or orchestration environment.  Windows-specific and MacOS-specific steps are provided as well as instructions which apply universally.

## Windows Specific Steps

* Install Windows Subsystem for Linux **(for Windows laptops)**: [https://docs.microsoft.com/en-us/windows/wsl/install](https://docs.microsoft.com/en-us/windows/wsl/install)
  - Ensure WSL version 2 is configured, from powershell type: `wsl -l -v` to check versions
  - **Ubuntu** is default and recommended
  - If Ubuntu is at WSL version 1, from powershell type: `wsl --set-version Ubuntu 2`
*  **Windows Users** should then install Docker Desktop for Windows: [https://docs.docker.com/desktop/windows/install/](https://docs.docker.com/desktop/windows/install/).
   - **Be sure to do this after installing WSL2**.  If you have installed Docker Desktop prior to installing WSL2, you may have problems using Docker from within WSL2.   In this case, it is reccomended that you uninstall Docker Desktop, and then re-install it.
* Configure Docker with WSL Integration: [https://docs.docker.com/desktop/windows/wsl/](https://docs.docker.com/desktop/windows/wsl/)
* Install git **within command line execution environment**:
  - Inside Windows Subsystem for Linux (WSL): `sudo apt-get install git-all`

## MacOS Specific Steps

The following steps are applicable to MacOS only.

* Install Docker via: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
  - Note: MacOS environments do not require an additional integration such as WSL
* Install Homebrew:
  - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
  - Additional info on Homebrew: [https://brew.sh/](https://brew.sh/)
* Install git:
  - `brew install git`

## Universal Tools

* Install [OpenLens](https://github.com/MuhammedKalkan/OpenLens)
* Install respective cloud provider CLI **within command line interface (i.e. WSL or MacOS)**:
  - Azure: [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
    - Follow specific instructions for **Windows Subsystem for Linux (WSL)** if this is the desired method
  - AWS: [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)

## VSCode

VSCode provides a flexible, well-integrated environment to perform Viya 4 deployments.  VSCode is optional and not required, but recommended for ease of code management with git as well as terminal functionality.

* [Download VSCode](https://code.visualstudio.com/download)
* [Getting Started with VSCode](https://code.visualstudio.com/docs/introvideos/basics)
