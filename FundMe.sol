// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error NotOwner();

import {PriceConverter} from "./PriceConverter.sol";
contract FundMe {
    address public immutable i_owner;
    using PriceConverter for uint256;
    address[] public funders;
    uint256 constant MINIMUN_USD = 1e18;
    mapping(address funder => uint256 amountFunded) public addrToFundedAmount;

    constructor(){
        i_owner = msg.sender;   
    }

    function fund() public payable{
        // Allow user to send money
        require(msg.value.getConversionRate() > MINIMUN_USD, "insufficient fund in wallet");
        // add the sender to the funder array to keep record
        funders.push(msg.sender);
        //set the mapping for access of amount sent
        addrToFundedAmount[msg.sender] += msg.value;
    }

    
    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addrToFundedAmount[funder] = 0;
        }
        // reset the funder array 
        funders = new address[](0);

        // how to withdrew 
        //send returns bool, transfer returns nothing
        // call returns (bool, bytedata)
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "send failed");

        // //transfer method
        // payable(msg.sender).transfer(address(this).balance);

        //call method
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }
    receive() external payable { 
        //contract recieve funds without directly calling fund()
        //money is sent directly to wallet, it triggers the fund()
        fund();
    }
    fallback() external payable { 
        //contract is triggered with invalid function data in callback
        fund();
    }
    modifier  onlyOwner(){
        // require(msg.sender == i_owner, "Only owner can make this call");
        if(msg.sender != i_owner){revert NotOwner();}
        _;
    }

    

}