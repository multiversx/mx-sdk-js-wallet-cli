#!/usr/bin/env bash

WALLETJS="./index.js"

code() {
    printf "\n\`\`\`\n" >> README.md
}

cliCommand() {
    printf "### $1\n\n" >> README.md

    code
    printf "$ erdwalletjs $2 --help\n" >> README.md
    ${WALLETJS} ${2} --help >> README.md
    code
    printf "\n\n" >> README.md
}

generate() {
    echo -n > README.md
    printf "# mx-sdk-js-wallet-cli\n\n" >> README.md

    printf "## Overview\n\n" >> README.md
    printf "**sdk-wallet-cli** is a light CLI wrapper over [@multiversx/sdk-wallet](https://www.npmjs.com/package/@multiversx/sdk-wallet) and allows one to generate mnemonics, derive key files and sign MultiversX transactions.\n" >> README.md
    printf "It exposes the following **commands**, via the `mxjs-wallet` alias:\n\n" >> README.md

    code
    printf "$ erdwalletjs --help\n" >> README.md
    ${WALLETJS} --help >> README.md
    code

    cliCommand "New Mnemonic" "new-mnemonic"
    cliCommand "Derive Key File" "derive-key"
    cliCommand "Sign" "sign"
}

