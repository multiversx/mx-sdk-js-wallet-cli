SANDBOX=./testdata-out
WALLETJS="../index.js"

testAll() {
    testErrors || return 1
    testHappyCases || return 1
}

testHappyCases() {
    cleanSandbox
    echo "> Alice creates a mnemonic"
    ${WALLETJS} new-mnemonic -m ${SANDBOX}/mnemonicOfAlice.txt || return 1
    echo "> Alice derives a key, index = 0"
    ${WALLETJS} derive-key -m ${SANDBOX}/mnemonicOfAlice.txt -k ${SANDBOX}/keyOfAlice.json -p ./testdata/passwordOfAlice.txt || return 1
    echo "> Alice derives another key, index = 1"
    ${WALLETJS} derive-key -m ${SANDBOX}/mnemonicOfAlice.txt -n 1 -k ${SANDBOX}/keyOfAlice-sCat.json -p ./testdata/passwordOfAlice-sCat.txt || return 1
    echo "> Alice signs a transaction"
    ${WALLETJS} sign -i ./testdata/txToBob42.json -o ${SANDBOX}/txToBob42Signed.json -k ${SANDBOX}/keyOfAlice.json -p ./testdata/passwordOfAlice.txt || return 1
    echo "> Alice's cat signs a transaction"
    ${WALLETJS} sign -i ./testdata/txToBob43.json -o ${SANDBOX}/txToBob43Signed.json -k ${SANDBOX}/keyOfAlice-sCat.json -p ./testdata/passwordOfAlice-sCat.txt || return 1

    assertFileExists ${SANDBOX}/mnemonicOfAlice.txt || return 1
    assertFileExists ${SANDBOX}/keyOfAlice.json || return 1
    assertFileExists ${SANDBOX}/keyOfAlice-sCat.json || return 1
    assertFileExists ${SANDBOX}/txToBob42Signed.json || return 1
    assertFileExists ${SANDBOX}/txToBob43Signed.json || return 1
}

testErrors() {
    cleanSandbox

    echo "Setup"
    echo "size effort awful stand explain learn route protect armed truck dilemma boy empower frown disorder derive gown element indoor wrist jewel outdoor uncover brave" > ${SANDBOX}/mnemonicOfAlice.txt
    ${WALLETJS} derive-key -m ${SANDBOX}/mnemonicOfAlice.txt -k ${SANDBOX}/keyOfAlice.json -p ./testdata/passwordOfAlice.txt || return 1

    echo "> Won't overwrite existing mnemonic"
    ${WALLETJS} new-mnemonic -m ${SANDBOX}/mnemonicOfAlice.txt 2>${SANDBOX}/error.txt
    assertFileContains ${SANDBOX}/error.txt "must not exist, it won't be overwritten" || return 1

    echo "> Derive using a non-existing password file"
    ${WALLETJS} derive-key -m ${SANDBOX}/mnemonicOfAlice.txt -k ${SANDBOX}/keyOfAlice.json -p ./thisDoesNotExist.txt 2>${SANDBOX}/error.txt
    assertFileContains ${SANDBOX}/error.txt "no such file or directory" || return 1

    echo "> Bad password"
    ${WALLETJS} sign -i ./testdata/txToBob42.json -o ${SANDBOX}/nothing.json -k ${SANDBOX}/keyOfAlice.json -p ./testdata/passwordOfAlice-sCat.txt 2>${SANDBOX}/error.txt
    assertFileContains ${SANDBOX}/error.txt "possibly wrong password" || return 1
}

cleanSandbox() {
    rm -rf ${SANDBOX}
    mkdir ${SANDBOX}
}

assertFileExists() {
    if [ ! -f "$1" ]
    then
        echo "Error: file [$1] does not exist!" 1>&2
        return 1
    fi

    echo "OK: file [$1] exists."
    return 0
}

assertFileContains() {
    if grep -q "$2" "$1"
    then
        echo "OK: found [$2]."
        return 0
    fi

    echo "Error: File [$1] does not contain [$2]!" 1>&2
    return 1
}
