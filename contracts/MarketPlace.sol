// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

contract MarketPlace {
    struct Item {
        uint256 itemId;
        string name;
        address payable owner;
        uint256 price;
        bool isSold;
        bool isActive;
        uint256 createdTimestamp;
    }

    event ItemCreated(uint256 indexed itemId, address owner, uint256 price);

    event ItemPurchased(
        uint256 indexed itemId,
        address seller,
        address buyer,
        uint256 purchasePrice
    );

    event ItemPriceChanged(uint256 itemId, uint256 newPrice);

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;

    mapping(uint256 => Item) internal items;
    Item[] itemList;

    constructor() {}

    function createItem(string memory _name, uint256 _price)
        external
        returns (uint256)
    {
        require(_price > 0, "price must be greater than 0");
        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        items[itemId] = Item(
            itemId,
            _name,
            payable(msg.sender),
            _price,
            false,
            true,
            block.timestamp
        );

        emit ItemCreated(itemId, msg.sender, _price);
        return itemId;
    }

    function changeItemPrice(uint256 _itemId, uint256 _newPrice) external {
        Item storage item = items[_itemId];
        require(item.isActive, "Inactive item");
        require(msg.sender == item.owner, "Only owner can change price");
        require(_newPrice > 0, "price must be greater than 0");
        item.price = _newPrice;
        items[_itemId] = item;
        emit ItemPriceChanged(_itemId, _newPrice);
    }

    function getItem(uint256 _itemId) external view returns (Item memory) {
        Item storage item = items[_itemId];
        return item;
    }

    function getItems() public returns (Item[] memory) {
        uint256 itemCount = _itemIds.current();
        for (uint256 i = 0; i < itemCount; i++) {
            if (!items[i].isSold) {
                itemList.push(items[i]);
            }
        }
        return itemList;
    }

    function purchaseItem(uint256 _itemId) external payable {
        Item storage item = items[_itemId];
        uint256 price = item.price;
        address payable seller = payable(item.owner);
        require(msg.value >= price, "You should include the price of the item");
        require(msg.sender != seller, "seller can not buy its owned item");

        item.isSold = true;
        item.isActive = false;
        item.owner = payable(msg.sender);
        items[_itemId] = item;
        seller.transfer(msg.value);

        emit ItemPurchased(_itemId, seller, msg.sender, price);
    }
}
