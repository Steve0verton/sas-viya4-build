# NFS Mounts

[NFS storage](https://www.techtarget.com/searchenterprisedesktop/definition/Network-File-System) (**N**etwork **F**ile **S**torage) is the common storage medium by default for Viya 4 environments and a very commonly used mechanism to share data across multiple mount points within a local network.  The [SAS Github outlines default volumes and directories setup during the viya4-deployment process](https://github.com/sassoftware/viya4-deployment#storage).

The NFS server setup during the Viya 4 deployment is used to mount permanent data storage behind SAS services such as CAS, Consul and RabbitMQ.  Other data can be stored such as SAS datasets, flat files, astores and user home directories.

**Table of Contents:**
- [Connecting to the NFS Server](#connecting-to-the-nfs-server)
- [Transfering Data for CAS](#transfering-data-for-cas)

## Connecting to the NFS Server

SSH can be used to connect to the NFS server to explore file systems and directories running on the NFS server.  The following command provides a simple way to connect using the same SSH private key used during the Viya 4 deployment process (i.e. DAC).  The NFS admin username and NFS Public IP are provided after Terraform completes the IAC deployment.  These values can be determined using Azure Management Portal or the Terraform command line tool.

```bash
# Connect to the NFS Virtual Machine
ssh -i ~/.ssh/azure {{NFS_ADMIN_USERNAME}}@{{NFS_PUBLIC_IP}}
```

By default, physical directories used for the NFS server are found within `/export`.  The `V4_CFG_RWX_FILESTORE_PATH` variable defines the path. For additional file storage configuration options, refer to the [RWS Filestore section](https://github.com/sassoftware/viya4-deployment/blob/f2a03427e11b4501f0d0cc06778a98aa2c157673/docs/CONFIG-VARS.md#rwx-filestore) in the viya4-deployment Github documentation.

The following example command connects to the NFS server.

```bash
ssh -i ~/.ssh/azure nfsuser@123.123.123.123
```

## Transfering Data for CAS

SFTP client tools such as [WinSCP](https://winscp.net/eng/index.php) or [Forklift](https://binarynights.com/) (for MacOS) can also be used to transfer files to and from the subdirectories within `/export` so they are available within the SAS Environment.  Command line tools such as the `scp` command can also be used.  Use the same connection details from the previous section to define a connection to the NFS server (SSH key, username and public IP of the NFS server).

The following directory path provides an example file path for data behind out-of-box CAS libraries:
`/export/pvs/oc-dev-ns-cas-default-data-pvc-{{HASH}}/caslibs`

**Tip:** if the file path cannot be located, SSH into the NFS server using the instructions above, then browse from the root filesystem and look for relevant named directories (i.e. export, pv, etc).
