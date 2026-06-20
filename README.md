# generic
Generic Docker Images

## Golang

The Golang image builds from `generic/golang/Dockerfile`.

Build it from the repository root so Docker can include the root, generic, and
image-specific `shared.sh` files:

```sh
docker build -f generic/golang/Dockerfile --build-arg GO_VERSION=1.26.4 .
```

CI resolves the build matrix by fetching the latest stable releases from
`https://golang.org/dl/?mode=json`, then appending the pinned older versions in
`generic/golang/versions.yml`.

Published tags:

- `latest` for the newest resolved stable release
- `<major>.<minor>` for each resolved release line
- `<major>.<minor>.<patch>` for each exact resolved release
- `<major>.<minor>.<patch>-<sha>` for commit-specific rebuilds
