// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    /**
     * @dev {tokenURI}を計算するための_baseTokenURI。
     * 設定された場合、各トークンの結果のURIは、 `baseURI` と `tokenId` を連結したものになる。
     */
    string _baseTokenURI;

    // _price は1つの Crypto Dev NFT の価格です。
    uint256 public _price = 0.01 ether;

    // _pausedは、緊急時にコントラクトを一時停止するために使用されます
    bool public _paused;

    // CryptoDevsの最大数
    uint256 public maxTokenIds = 20;

    // ミントされるtokenIdsの総数
    uint256 public tokenIds;

    IWhitelist whitelist;

    // プリセールが開始されたかどうかを記録するためのブーリアン。
    bool public presaleStarted;

    // プリセール終了のタイムスタンプ
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor (string memory baseURI, address whitelistContract) ERC721 ("Crypto Devs", "CD") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    /**
     * @dev startPresale whitelistのアドレスに対してプリセールを開始します。
     */
    function startPresale() public onlyOwner {
        presaleStarted = true;
        // プリセール終了時刻を現在のタイムスタンプ＋5分とする。
        // Solidity には、タイムスタンプ (秒、分、時間、日、年) のためのクールな構文があります。
        presaleEnded = block.timestamp + 5 minutes;
    }

    /** 
     * @dev presaleMintは、プリセール期間中に1トランザクションにつき1つのNFTをミンティングすることができます。
     */
    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        // _safeMint は _mint 関数の安全なバージョンで、次のことを保証します。
        // ミントされるアドレスがコントラクトである場合、ERC721トークンの扱い方を知っています。
        // ミントされるアドレスがコントラクトでない場合は、_mintと同じように動作します。
        _safeMint(msg.sender, tokenIds);
    }

    /** 
     * @dev mintは、プリセール終了後、1回の取引で1NFTをmintすることができます。
     */
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    /**
     * @dev _baseURI は Openzeppelin の ERC721 実装を上書きするもので、デフォルトでは baseURI に空の文字列を返します。
     */
     function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev setPaused は、コントラクトを一時停止または一時停止解除します。
     */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    /**
     * @dev withdrawは、コントラクトに含まれるすべてのエーテルをコントラクトのオーナーに送ります。
     */
    function withdraw() public onlyOwner  {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Etherを受信する関数。msg.dataは空でなければならない。
    receive() external payable {}

    // msg.data が空でないときにフォールバック関数が呼ばれる
    fallback() external payable {}
}