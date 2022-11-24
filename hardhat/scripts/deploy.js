const { ethers } = require("hardhat")
require("dotenv").config({ path: ".env" })
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants")

async function main() {
  // 前のモジュールでデプロイしたwhitelistコントラクトのアドレス
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS
  // Crypto Dev NFTのメタデータを抽出するためのURL
  const metadataURL = METADATA_URL
  /*
   * ethers.jsのContractFactoryは、新しいスマートコントラクトをデプロイするために使用される抽象化されたものです。
   * CryptoDevsContractは、CryptoDevsコントラクトのインスタンス用のファクトリです。
   */
  const cryptoDevsContract = await ethers.getContractFactory("CryptoDevs")

  // コントラクトをデプロイ
  const deployedCryptoDevsContract = await cryptoDevsContract.deploy(
    metadataURL,
    whitelistContract
  )

  // デプロイされたコントラクトのアドレスを表示する
  console.log(
    "Crypto Devs Contract Address:",
    deployedCryptoDevsContract.address
  )
}

// main関数を呼び出して、エラーがあればキャッチする。
main().then(() => process.exit(0)).catch((error) => {
    console.error(error)
    process.exit(1)
})