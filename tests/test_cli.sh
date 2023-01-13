SANDBOX=./testdata-out
WALLETJS="../index.js"

testAll() {
    testHappyCases || return 1
    testErrors || return 1
}

testHappyCases() {
    cleanSandbox

    testMnemonicGeneration || return 1
    testKeyDerivation || return 1
    testSigning || return 1
}

testMnemonicGeneration() {
    echo ">  creates a mnemonic"
    ${WALLETJS} new-mnemonic -m ${SANDBOX}/mnemonic.txt || return 1

    assertFileExists ${SANDBOX}/mnemonic.txt || return 1
}

testKeyDerivation() {
    echo "> Alice derives a key, index = 0"
    ${WALLETJS} derive-key -m ./testdata/mnemonic.txt -k ${SANDBOX}/keyOfAlice.json -p ./testdata/passwordOfAlice.txt || return 1
    echo "> Alice derives another key, index = 1"
    ${WALLETJS} derive-key -m ./testdata/mnemonic.txt -n 1 -k ${SANDBOX}/keyOfBob.json -p ./testdata/passwordOfBob.txt || return 1

    assertFileExists ${SANDBOX}/keyOfAlice.json || return 1
    assertFileExists ${SANDBOX}/keyOfBob.json || return 1
}

testSigning() {
    echo "> Alice signs a transaction"
    ${WALLETJS} sign -i ./testdata/txAliceToCarol.json -o ${SANDBOX}/txAliceToCarolSigned.json -k ${SANDBOX}/keyOfAlice.json -p ./testdata/passwordOfAlice.txt || return 1
    echo "> Alice's cat signs a transaction"
    ${WALLETJS} sign -i ./testdata/txBobToCarol.json -o ${SANDBOX}/txBobToCarolSigned.json -k ${SANDBOX}/keyOfBob.json -p ./testdata/passwordOfBob.txt || return 1

    assertFileExists ${SANDBOX}/txAliceToCarolSigned.json || return 1
    assertFileExists ${SANDBOX}/txBobToCarolSigned.json || return 1

    assertFileContains ${SANDBOX}/txAliceToCarolSigned.json "e9230a7793646074cc239705385f8ca38f2c9da3d4497fbe322536338004c38690a83237da75033ff12827368f5077e3ae0f9e403ab01688b355734dc952d905" || return 1
    assertFileContains ${SANDBOX}/txBobToCarolSigned.json "3ffb28d2836cae6ea458a6387b8f47fd3278691eee813e12da058659d0348cb3fc443aa7e0d6da6cba90e207935b0cadc78c82f2eff7adde603b3c4dab9c980e" || return 1
}

testErrors() {
    cleanSandbox

    echo "Setup"
    echo "size effort awful stand explain learn route protect armed truck dilemma boy empower frown disorder derive gown element indoor wrist jewel outdoor uncover brave" > ${SANDBOX}/mnemonic.txt
    ${WALLETJS} derive-key -m ${SANDBOX}/mnemonic.txt -k ${SANDBOX}/key.json -p ./testdata/password.txt || return 1

    echo "> Won't overwrite existing mnemonic"
    ${WALLETJS} new-mnemonic -m ${SANDBOX}/mnemonic.txt 2>${SANDBOX}/error.txt
    assertFileContains ${SANDBOX}/error.txt "must not exist, it won't be overwritten" || return 1

    echo "> Derive using a non-existing password file"
    ${WALLETJS} derive-key -m ${SANDBOX}/mnemonic.txt -k ${SANDBOX}/key.json -p ./thisDoesNotExist.txt 2>${SANDBOX}/error.txt
    assertFileContains ${SANDBOX}/error.txt "no such file or directory" || return 1

    echo "> Bad password"
    ${WALLETJS} sign -i ./testdata/empty.json -o ${SANDBOX}/nothing.json -k ${SANDBOX}/key.json -p ./testdata/passwordOfAlice.txt 2>${SANDBOX}/error.txt
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
