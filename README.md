# Prerequisites

- docker
- shipyard ([setup](https://shipyard.run/docs/install))

## Spin up the environment

```shell
shipyard run github.com/eveld/fermyon-installer
```

## Get the endpoints for consul, nomad, traefik

```shell
shipyard env
```

## Clean up the environment

```shell
shipyard destroy
```
