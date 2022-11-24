export default function handler(req, res) {
    // クエリパラメータからtokenIdを取得します。
    const tokenId = req.query.tokenId;
    // 画像はすべてgithubにアップロードされているため、githubから直接画像を抽出することができます。
    const image_url =
      "https://raw.githubusercontent.com/LearnWeb3DAO/NFT-Collection/main/my-app/public/cryptodevs/";
    // APIがCrypto Devのメタデータを送り返しています。
    // コレクションをOpenseaと互換性を持たせるために、いくつかのメタデータの標準に従う必要があります。
    // apiからのレスポンスを返送するとき
    // 詳細はこちら: https://docs.opensea.io/docs/metadata-standards
    res.status(200).json({
      name: "Crypto Dev #" + tokenId,
      description: "Crypto Dev is a collection of developers in crypto",
      image: image_url + tokenId + ".svg",
    });
  }