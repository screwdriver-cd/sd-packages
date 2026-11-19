# sd-packages
Kata custom kernel, custom os, Skopeo, ztsd binary build pipeline

## Dependencies
1. skopeo is a command line utility that performs various operations on container images and image repositories.
LICENSE:https://github.com/containers/skopeo/blob/master/LICENSE
2. Zstandard, or zstd as short version, is a fast lossless compression algorithm, targeting real-time compression scenarios at zlib-level and better compression ratios
LICENSE:https://github.com/facebook/zstd/blob/dev/LICENSE

## macOS zstd archive

`zstd-cli-macosx.tar.gz` contains the zstd 1.5.6 executable for macOS x86_64
and the following license files:

- [LICENSE.zstd](LICENSE.zstd): the zstd copyright notice and BSD-3-Clause text,
  copied from [zstd v1.5.6](https://github.com/facebook/zstd/blob/v1.5.6/LICENSE).
- [LICENSE.divsufsort](LICENSE.divsufsort): the copyright notice and MIT text for
  divsufsort included in zstd, copied from the
  [zstd v1.5.6 source header](https://github.com/facebook/zstd/blob/v1.5.6/lib/dictBuilder/divsufsort.c).

The `zstd-mac` job publishes this archive as-is. When replacing the executable,
update the license files to match its version and include them in the archive.
From a directory containing the executable and both license files, run:

```sh
tar -czf zstd-cli-macosx.tar.gz ./zstd ./LICENSE.zstd ./LICENSE.divsufsort
```
