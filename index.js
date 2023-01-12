#!/usr/bin/env node

const os = require("os");
const fs = require("fs");
const { Command } = require("commander");
const core = require("@multiversx/sdk-core");
const wallet = require("@multiversx/sdk-wallet");

main();

function main() {
    const program = new Command();
    program.version("2.0.0");
    setupCli(program);

    try {
        program.parse(process.argv)
    } catch (error) {
        console.error(`Error: ${error.message}`);
    }
}

function setupCli(program) {
    program.name("mxjs-wallet")

    program
        .command("new-mnemonic")
        .description("Create a new mnemonic phrase (24 words)")
        .requiredOption("-m, --mnemonic-file <mnemonicFile>", "where to save the mnemonic")
        .action(newMnemonic);

    program
        .command("derive-key")
        .description("Derive a JSON key-file from an existing mnemonic phrase")
        .requiredOption("-m, --mnemonic-file <mnemonicFile>", "a file containing the mnemonic")
        .option("-n, --account-index <accountIndex>", "the account index to derive", "0")
        .requiredOption("-k, --key-file <keyFile>", "the key-file to create")
        .requiredOption("-p, --password-file <passwordFile>", "a file containing the password for the key-file")
        .action(deriveKey);

    program
        .command("sign")
        .description("Sign a JSON transaction")
        .requiredOption("-i, --in-file <inFile>", "the file containing the JSON transaction")
        .requiredOption("-o, --out-file <outFile>", "where to save the signed JSON transaction")
        .requiredOption("-k, --key-file <keyFile>", "the key-file (the wallet)")
        .requiredOption("-p, --password-file <passwordFile>", "the file containing the key-file password")
        .action(signMessage);
}

function newMnemonic(cmdObj) {
    let mnemonicFile = asUserPath(cmdObj.mnemonicFile);
    let mnemonic = wallet.Mnemonic.generate();
    let words = mnemonic.getWords();
    let mnemonicString = words.join(" ");

    writeToNewFile(mnemonicFile, `${mnemonicString}\n`)
    console.log(`Mnemonic saved to file: [${mnemonicFile}].`);
    console.log(`\n${mnemonicString}\n`);
}

function deriveKey(cmdObj) {
    let mnemonicFile = asUserPath(cmdObj.mnemonicFile);
    let accountIndex = parseInt(cmdObj.accountIndex) || 0;
    let keyFile = asUserPath(cmdObj.keyFile);
    let passwordFile = asUserPath(cmdObj.passwordFile);

    let mnemonicString = readText(mnemonicFile);
    let password = readText(passwordFile);

    let mnemonic = wallet.Mnemonic.fromString(mnemonicString);
    let userSecretKey = mnemonic.deriveKey(accountIndex);
    let userPublicKey = userSecretKey.generatePublicKey();
    let userAddress = userPublicKey.toAddress();
    let userWallet = new wallet.UserWallet(userSecretKey, password);
    let userWalletJson = JSON.stringify(userWallet.toJSON(), null, 4);

    console.log(`Derived key for account index = ${accountIndex}, address = ${userAddress}.`);
    console.log(`Encrypted with password from [${passwordFile}] and saved to file: [${keyFile}].`);
    writeToNewFile(keyFile, `${userWalletJson}\n`);
}

function signMessage(cmdObj) {
    let inFile = asUserPath(cmdObj.inFile);
    let outFile = asUserPath(cmdObj.outFile);
    let keyFile = asUserPath(cmdObj.keyFile);
    let passwordFile = asUserPath(cmdObj.passwordFile);

    let inFileJson = readText(inFile);
    let message = JSON.parse(inFileJson);
    let keyFileJson = readText(keyFile);
    let keyFileObject = JSON.parse(keyFileJson);
    let password = readText(passwordFile);
    let userSigner = wallet.UserSigner.fromWallet(keyFileObject, password);

    let transaction = new core.Transaction({
        nonce: message.nonce,
        sender: userSigner.getAddress(),
        receiver: new core.Address(message.receiver),
        value: message.value,
        gasPrice: message.gasPrice,
        gasLimit: message.gasLimit,
        data: new core.TransactionPayload(message.data),
        chainID: message.chainID,
        version: message.version
    });

    userSigner.sign(transaction);
    let signedTransactionJson = JSON.stringify(transaction.toPlainObject(), null, 4);

    writeToNewFile(outFile, `${signedTransactionJson}\n`);
}

function asUserPath(userPath) {
    return (userPath || "").replace("~", os.homedir);
}

function readText(filePath) {
    return fs.readFileSync(filePath, { encoding: "utf8" }).trim();
}

function writeToNewFile(filePath, content) {
    if (fs.existsSync(filePath)) {
        throw new Error(`File ${filePath} must not exist, it won't be overwritten.`);
    }

    fs.writeFileSync(filePath, content);
}
