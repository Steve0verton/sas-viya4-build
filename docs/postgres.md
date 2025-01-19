# PostgreSQL

This document provides information related to managing, administering and connecting to the PostgreSQL database which powers Viya 4 (i.e. SharedServices).

## pgAdmin

[pgAdmin](https://www.pgadmin.org/download/) is a client tool to connect to a PostgreSQL databases.  This can be installed through standard installation packages or by using Docker compose.

### Install pgAdmin Using Docker Compose

Run the following command to deploy pgAdmin inside of a Docker container.

```bash
# From this project repository, navigate to the utilities/pgAdmin directory
cd utilities/pgAdmin

# Run Docker compose
docker-compose up -d
```

## Connecting to PostgreSQL (Azure)

The following documentation is specific for external databases deployed on Microsoft Azure cloud.

Obtain the following pieces of information to define a new server connection in pgAdmin:

1. **Hostname** of DB server
2. **Username** - defined in the IAC configuration
3. **Password** - defined in the IAC configuration

Create a new server connection and enter the previous information. Ensure the `sslmode` on the Parameters configuration is set to `require`.
