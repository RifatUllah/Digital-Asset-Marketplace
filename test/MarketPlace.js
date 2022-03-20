const { expect } = require("chai");
const { ethers } = require('hardhat')

describe("Marketplace contract", function () {

    let seller;
    let buyer;
    let marketplaceContract;
    before(async function () {
        [seller, buyer] = await ethers.getSigners();

        const marketplaceContractFacttory = await ethers.getContractFactory("MarketPlace");
        marketplaceContract = await marketplaceContractFacttory.deploy();
    });

    describe("Purchase Item", function () {

        it("Should item create", async () => {

            const itemName = "CHECK PRINT SHIRT";
            const itemPrice = ethers.utils.parseEther("110");

            const transaction = await marketplaceContract.connect(seller).createItem(itemName, itemPrice);
            const receipt = await transaction.wait();
            const event = receipt.events[0].args;

            expect(event.owner).to.equal(seller.address);
            expect(event.price).to.equal(itemPrice);

        });

        it("Should item purchase", async () => {

            const itemName = "CHECK PRINT SHIRT";
            const itemPrice = ethers.utils.parseEther("110");

            var sellerBalance = await ethers.provider.getBalance(seller.address);
            console.log(ethers.utils.formatEther(sellerBalance));
            var transaction = await marketplaceContract.connect(seller).createItem(itemName, itemPrice);
            var receipt = await transaction.wait();
            var event = receipt.events[0].args;

            const itemId = receipt.events[0].args[0];
            console.log("itemId " + itemId);

            const purchasePrice = ethers.utils.parseEther("110");

            transaction = await marketplaceContract.connect(buyer).purchaseItem(itemId, { value: purchasePrice });
            receipt = await transaction.wait();
            event = receipt.events[0].args;


            expect(event.seller).to.equal(seller.address);
            expect(event.buyer).to.equal(buyer.address);
            expect(event.purchasePrice).to.equal(purchasePrice);
            sellerBalance = await ethers.provider.getBalance(seller.address);
            console.log(ethers.utils.formatEther(sellerBalance));
        });
    });


});