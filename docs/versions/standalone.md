<!-- generated-compatible docs; update when standalone variants change -->

# Standalone

Standalone images include only the shared generic setup, without a language runtime.
The full variant adds common build tooling; the Alpine variant stays minimal.

Image path for this repository:

`ghcr.io/michlip-eu/generic/standalone`

For forks or other repositories, use:

`ghcr.io/<owner>/<repo>/standalone`

## Variants

| Variant | Base image | Tags | Included packages | Architectures |
| --- | --- | --- | --- | --- |
| `full` | `debian:bookworm-slim` | `latest`, `latest-<sha>` | `bash`, `ca-certificates`, `curl`, `gcc/g++`, `git`, `make`, `openssh-client`, `pkg-config` | `linux/amd64`, `linux/arm64` |
| `alpine` | `alpine:latest` | `latest-alpine`, `latest-alpine-<sha>` | `bash`, `ca-certificates` | `linux/amd64`, `linux/arm64` |

## Pull Commands

```sh
docker pull ghcr.io/michlip-eu/generic/standalone:latest
docker pull ghcr.io/michlip-eu/generic/standalone:latest-alpine
```

## Included Setup

Both variants run:

- `shared.sh` from the repository root
- `generic/shared.sh`
- `generic/standalone/shared.sh`

The root shared setup installs `bash` and `ca-certificates`, plus any optional packages supplied through `GENERIC_ADDITIONAL_PACKAGES` or `GENERIC_ADDITIONAL_FULL_PACKAGES`.
