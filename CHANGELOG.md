# Changelog

## [0.4.0](https://github.com/noahdotpy/idwt/compare/v0.3.0...v0.4.0) (2024-12-11)


### Features

* improve config readability by moving modules into their own modules section ([901c63c](https://github.com/noahdotpy/idwt/commit/901c63cc7f0d5d76e81226335c634c32604e1209))


### Bug Fixes

* apply system all now also runs block_flatpaks as it sohld ([6dce0f5](https://github.com/noahdotpy/idwt/commit/6dce0f5851d385b30169102c5571f0fdcff681b4))
* block_flatpaks now properly handles errors from cleaning up ([e69db13](https://github.com/noahdotpy/idwt/commit/e69db13f4e6df27674b905dc13c9fe23fc46bed3))
* edit command now should use proper order of checking what to do ([850e643](https://github.com/noahdotpy/idwt/commit/850e643f36d52f476968faca2cb03db8d425cb46))
* revoke_admin now skips any users that aren't also in affected-users ([32387d7](https://github.com/noahdotpy/idwt/commit/32387d727541f57344729248abbb69d37b4cd63b))

## [0.3.0](https://github.com/noahdotpy/idwt/compare/v0.2.1...v0.3.0) (2024-12-11)


### Features

* implement block_flatpaks module ([051a5b2](https://github.com/noahdotpy/idwt/commit/051a5b20b588fce95615183954f9820ce58c45fb))

## [0.2.1](https://github.com/noahdotpy/idwt/compare/v0.2.0...v0.2.1) (2024-12-06)


### Bug Fixes

* unhide get-config from help ([8974271](https://github.com/noahdotpy/idwt/commit/89742718590ecb19c39e6c3fa4c44f723a72c0a4))

## [0.2.0](https://github.com/noahdotpy/idwt/compare/v0.1.0...v0.2.0) (2024-12-06)


### Features

* add `idwt edit` command ([e67807e](https://github.com/noahdotpy/idwt/commit/e67807eb5dae39af19aad17d40f49c43c77ec9ee))
* add get-config command ([a497dba](https://github.com/noahdotpy/idwt/commit/a497dba2e12ee73479d7966131fe7b555fdd1007))
* implement `idwt apply system all`, chore: structure for tighten ([bb5a204](https://github.com/noahdotpy/idwt/commit/bb5a204e93dee41533f08201a80f0e0a5749518c))
* implement block-networking ([1c7eef2](https://github.com/noahdotpy/idwt/commit/1c7eef26b0000c469214810a0f8ba49db14b444e))
* implement revoke-admin ([0dbbc6e](https://github.com/noahdotpy/idwt/commit/0dbbc6e590966d5192302c616c5ffd84fb595cca))


### Bug Fixes

* **block-networking:** now uses the iptables command directly ([ead07a6](https://github.com/noahdotpy/idwt/commit/ead07a6bc2b6fc8745af543086b99404ba247a90))
