# generic
Generic Docker Images

## Runtime Docs

- [Golang](docs/versions/golang.md)
- [Standalone](docs/versions/standalone.md)

## Golang

The Golang image builds from `generic/golang/Dockerfile` in two variants:

- `full`: Debian slim with common build tooling like Git, SSH client, C/C++
  compilers, Make, curl, and pkg-config
- `alpine`: Alpine-based minimal image

Build it from the repository root so Docker can include the root, generic, and
image-specific `shared.sh` files:

```sh
docker build -f generic/golang/Dockerfile --build-arg GO_VERSION=1.26.4 .
docker build -f generic/golang/Dockerfile --build-arg BASE_IMAGE=alpine:latest --build-arg IMAGE_VARIANT=alpine --build-arg GO_VERSION=1.26.4 .
```

CI resolves the build matrix by fetching stable releases from
`https://golang.org/dl/?mode=json`, merging every matching upstream Go git tag,
then appending the pinned versions in `generic/golang/versions.yml`.

The resolver rewrites `generic/golang/versions.yml` with the discovered latest
versions, so releases remain known after they disappear from the Go download API.

Published tags:

- `latest`, `<major>.<minor>`, and `<major>.<minor>.<patch>` for the full image
- `latest-alpine`, `<major>.<minor>-alpine`, and
  `<major>.<minor>.<patch>-alpine` for the Alpine image
- `<major>.<minor>.<patch>-<sha>` and
  `<major>.<minor>.<patch>-alpine-<sha>` for commit-specific rebuilds

See [docs/versions/golang.md](docs/versions/golang.md) for the generated
version, tag, and deprecation list.
