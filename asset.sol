pragma solidity ^0.8.4;

contract AssetContract {

    struct Asset {
        uint256 id;
        address payable owner;
        uint256 price;
        uint256 totalStakes;
        uint256 availableStakes;
        mapping(address => uint256) stakes;
    }

    uint256 public nextAssetId;
    mapping(uint256 => Asset) public assets;

    function createAsset(uint256 price, uint256 totalStakes) public {
        Asset storage newAsset = assets[nextAssetId];
        newAsset.id = nextAssetId;
        newAsset.owner = payable(msg.sender);
        newAsset.price = price;
        newAsset.totalStakes = totalStakes;
        newAsset.availableStakes = totalStakes;
        nextAssetId++;
    }

    function purchaseStakes(uint256 assetId, uint256 stakes) public payable {
        Asset storage asset = assets[assetId];
        require(stakes > 0, "Must purchase at least one stake");
        require(stakes <= asset.availableStakes, "Not enough available stakes");
        require(msg.value >= stakes * asset.price, "Not enough amount of ether sent");

        if (msg.value > (stakes * asset.price)) {
            asset.owner.transfer(msg.value - (stakes * asset.price));
        } else {
            asset.owner.transfer(msg.value);
        }
        
        asset.stakes[msg.sender] += stakes;
        asset.availableStakes -= stakes;

    }

    function getAsset(uint256 assetId) public view returns (uint256, address, uint256, uint256, uint256) {
        Asset storage asset = assets[assetId];
        return (asset.id, asset.owner, asset.price, asset.totalStakes, asset.availableStakes);
    }

    function getStakes(uint256 assetId, address buyer) public view returns (uint256) {
        Asset storage asset = assets[assetId];
        return asset.stakes[buyer];
    }

}