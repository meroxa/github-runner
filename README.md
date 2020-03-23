# base-github-runner

Please see [github-runner](https://github.com/terradatum/github-runner).

## Build

This [Dockerfile](https://github.com/terradatum/base-github-runner/blob/master/Dockerfile) is designed to leverage the
Docker cache to its fullest, and therefore each script is run as a separate step. When using command chaining, these
multiple scripts fail or succeed collectively - thus, if a single script fails near the end of the chain, the entire
chain's cache is invalidated.

## Installed software

* [Ubuntu1604](Ubuntu1604-README.md)
* [Ubuntu1804](Ubuntu1804-README.md)
