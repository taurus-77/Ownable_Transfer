//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./utils/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract AWSTERC1155 is ERC1155, Ownable, Pausable {
    mapping(uint256 => string) private _tokenURIs;
    uint256 public currentTokenID;
    mapping(uint256 => bool) isRevealed;
    string public defaultURI;

    constructor(address _newOwner)
        ERC1155("https://gateway.pinata.cloud/ipfs/")
        Ownable(_newOwner)
    {
        defaultURI = "https://gateway.pinata.cloud/ipfs/QmV9AMFXQXmLvdyKs2vsAwQB729cyPAFqe5ZZKE2FYi3EB";
    }

    function uri(uint256 _id) public view override returns (string memory) {
        if (isRevealed[_id]) {
            return _tokenURIs[_id];
        } else {
            return defaultURI;
        }
    }

    function setURI(uint256 _tokenId, string memory _uri) public onlyOwner {
        _tokenURIs[_tokenId] = _uri;
    }

    function setBatchURI(uint256[] memory ids, string[] memory uris)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < ids.length; i++) {
            setURI(ids[i], uris[i]);
        }
    }

    function mint(
        address account,
        uint256 amount,
        string memory _uri,
        bytes memory data
    ) public onlyOwner {
        _mint(account, _getNextTokenID(), amount, data);
        setURI(_getNextTokenID(), _uri);
        _incrementTokenId();
    }

    // In case of auto increment ids and single base URI
    function mintBatch(
        address to,
        uint256 tokenCount,
        string memory _baseURI,
        uint256[] memory values,
        bytes memory data
    ) public onlyOwner {
        uint256[] memory ids = new uint256[](tokenCount);
        string[] memory uris = new string[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            ids[i] = _getNextTokenID();
            uris[i] = string(
                abi.encodePacked(
                    _baseURI,
                    "/",
                    Strings.toString(ids[i]),
                    ".json"
                )
            );
            _incrementTokenId();
        }
        _mintBatch(to, ids, values, data);
        setBatchURI(ids, uris);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        if (!isRevealed[id]) {
            isRevealed[id] = true;
        }
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function burn(
        address owner,
        uint256 id,
        uint256 value
    ) public onlyOwner {
        _burn(owner, id, value);
    }

    function burnBatch(
        address owner,
        uint256[] memory ids,
        uint256[] memory values
    ) public onlyOwner {
        _burnBatch(owner, ids, values);
    }

    function _getNextTokenID() private view returns (uint256) {
        return currentTokenID + 1;
    }

    /**
     * @dev increments the value of _currentTokenID
     */
    function _incrementTokenId() private {
        currentTokenID++;
    }
}
