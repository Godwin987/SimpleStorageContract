// SPDX-License-Identifier: MIT
pragma solidity  0.8.25;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    mapping(address => uint256) public addressToAmountFunded;
    event LogMinimumUSD(uint256 minimumUSD);
    address[] public funders;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable {
        // convert the value of money sent to $50
        uint256 minimumUSD = 50;
        // Log the value of minimumUSD
        emit LogMinimumUSD(minimumUSD);
        
        require(getConversionRate(msg.value) >= minimumUSD, "You need to Spend more ETH!"); // the token sent must be >= $50
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        // conversion rate ETH -> USD for accepting tokens
    }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }

	function getPrice() public view returns (uint256){
		AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
		(,int256 answer,,,) = priceFeed.latestRoundData();
		return uint256(answer);
	}

//246026758563000000000
    function getConversionRate(uint ethAmount) public view returns (uint256){
    // ethPrice should be in USD with 8 decimal places, e.g., 245337747924 represents $2453.37747924
    uint256 ethPrice = getPrice(); // This should return something like 245337747924
    uint256 ethAmountInUsd = ((ethPrice * ethAmount)) / 1e18; // COnversion from GWEI denomination to USD equivalent.
    return (ethAmountInUsd);
    }

    modifier OnlyOwner{
        require(msg.sender == owner);
        _;
    }

    function withdraw() payable OnlyOwner public {
        payable(msg.sender).transfer(address(this).balance); // Withdraw funds in the contract to the address that calls this function.
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}

