# mx-sdk-js-wallet-cli

## Overview

**sdk-wallet-cli** is a light CLI wrapper over [@multiversx/sdk-wallet](https://www.npmjs.com/package/@multiversx/sdk-wallet) and allows one to generate mnemonics, derive key files and sign MultiversX transactions.
It exposes the following **commands**, via the `mxjs-wallet` alias:


```
$ mxjs-wallet --help
Usage: mxjs-wallet [options] [command]

Options:
  -V, --version           output the version number
  -h, --help              display help for command

Commands:
  new-mnemonic [options]  Create a new mnemonic phrase (24 words)
  derive-key [options]    Derive a JSON key-file from an existing mnemonic
                          phrase
  sign [options]          Sign a JSON transaction
  help [command]          display help for command

```
### New Mnemonic


```
$ mxjs-wallet new-mnemonic --help
Usage: mxjs-wallet new-mnemonic [options]

Create a new mnemonic phrase (24 words)

Options:
  -m, --mnemonic-file <mnemonicFile>  where to save the mnemonic
  -h, --help                          display help for command

```


### Derive Key File


```
$ mxjs-wallet derive-key --help
Usage: mxjs-wallet derive-key [options]

Derive a JSON key-file from an existing mnemonic phrase

Options:
  -m, --mnemonic-file <mnemonicFile>  a file containing the mnemonic
  -n, --account-index <accountIndex>  the account index to derive (default:
                                      "0")
  -k, --key-file <keyFile>            the key-file to create
  -p, --password-file <passwordFile>  a file containing the password for the
                                      key-file
  -h, --help                          display help for command

```


### Sign


```
$ mxjs-wallet sign --help
Usage: mxjs-wallet sign [options]

Sign a JSON transaction

Options:
  -i, --in-file <inFile>              the file containing the JSON transaction
  -o, --out-file <outFile>            where to save the signed JSON transaction
  -k, --key-file <keyFile>            the key-file (the wallet)
  -p, --password-file <passwordFile>  the file containing the key-file password
  -h, --help                          display help for command

```


