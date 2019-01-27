pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    SupplyChain supplyChain;
    uint public initialBalance = 10 ether;
    SupplyChain sc;
    SupplyChainUser seller;
    SupplyChainUser buyer;
    SupplyChainUser adversery;
    uint bookPrice = 10 wei;
    uint firstItemSku = 0;
    uint secondItemSku = 1;

    function beforeAll() public{
        Assert.equal(address(this).balance, 10 ether, "Contract was not deployed with initial balance of 1 ether");

        supplyChain = SupplyChain(DeployedAddresses.SupplyChain());


        seller = new SupplyChainUser(address(supplyChain));
        buyer = new SupplyChainUser(address(supplyChain));
        adversery = new SupplyChainUser(address(supplyChain));


        uint buyerMoney = bookPrice + 5 wei;
        address(buyer).transfer(buyerMoney);
    }



    function testAddItem() public
    {
        string memory name = "Book";
        string memory name1 = "Book1";
        string memory name2 = "Book2";

        //uint price = 10 wei;

        //add item to the supplychain
        bool item1Added = seller.addItem(name,bookPrice);
        bool item2Added = seller.addItem(name1,bookPrice);
        bool item3Added = seller.addItem(name2,bookPrice);

        Assert.isTrue(item1Added, "book added sucessfuly...");
        Assert.isTrue(item2Added, "book added sucessfuly...");
        Assert.isTrue(item3Added, "book added sucessfuly...");


    }

    // Test for failing conditions in this contracts
    // test that every modifier is working

    // buyItem
    // test for failure if user does not send enough funds

    function testBuyItemNotEnoughFunds() public{
        bool result = buyer.buyItem(firstItemSku, 1);
        Assert.isFalse(result, "Cannot buy item with insufficient funds");
    }


    // test for purchasing an item that is not for Sale
    function testBuyItemNotforSale() public{
        uint256 ItemNotForSale = 100;
        bool result = buyer.buyItem(ItemNotForSale, bookPrice);
        Assert.isFalse(result, "Cannot buy item that is not available");
    }

    // shipItem
     // test for calls that are made by not the seller
    function testShipItemNotSeller() public{
        bool result = adversery.shipItem(firstItemSku);
        Assert.isFalse(result, "Only seller can ship an item.");

    }
    // test for trying to ship an item that is not marked Sold
    function testShipItemNotSold() public{
        uint256 skuForItemNotSold = 2;
        bool result = seller.shipItem(skuForItemNotSold);
        Assert.isFalse(result, "Item not sold cannot be shipped....");
    }
    // receiveItem

    // test calling the function from an address that is not the buyer
    function testRecieveItemNotBuyer() public{
        bool result = adversery.receiveItem(secondItemSku);
        Assert.isFalse(result, "Enemy cannot receive item not marked shipped");
    }
    // test calling the function on an item not marked Shipped
    function testRecieveItemNotShipped() public{
        bool result = buyer.receiveItem(secondItemSku);
        Assert.isFalse(result, "Buyer cannot receive item not marked shipped");
    }


}

contract SupplyChainUser {

    address public supplyChain;

    constructor(address _supplyChain) public payable{
        supplyChain = _supplyChain;
    }


    // seller add item
    function addItem(string memory _item, uint _price) public returns (bool) {

        return SupplyChain(supplyChain).addItem(_item, _price);
    }
     // seller ship item
    function shipItem(uint _sku) public returns (bool){
        (bool retval, ) = address(supplyChain).call(abi.encodeWithSignature("shipItem(uint256)", _sku));
        return retval;
    }

    // buyer buy item
    function buyItem(uint _amount, uint _sku) public returns (bool){
        (bool retval, ) = address(supplyChain).call.value(_amount)(abi.encodeWithSignature("buyItem(uint256)", _sku));
        return retval;

    }
    // buyer recieve item
    function receiveItem(uint _sku) public returns (bool){
        (bool retval, ) = address(supplyChain).call(abi.encodeWithSignature("receiveItem(uint256)", _sku));
        return retval;
    }

    function() external payable{
    }
}






