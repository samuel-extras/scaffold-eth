// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  mapping ( address => uint256 ) public balances;


  uint256 public constant threshold = 1 ether;

  uint256 public deadline = block.timestamp + 120 seconds;

  bool public openForWithdraw;


  event Stake(address, uint256);

  event Received(address, uint);
   

constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

modifier notCompleted() {
    require(!exampleExternalContract.completed(), "The stake is already completed");
    _;
  }

  function stake() public payable {
    balances[msg.sender] += msg.value;
    
    emit Stake(msg.sender, msg.value);
  }

   

  

 


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value


  function execute() public notCompleted {
    if (timeLeft() == 0) {
      if (address(this).balance >= threshold) {
        // It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
        exampleExternalContract.complete{value: address(this).balance}();
      } else {
        // if the `threshold` was not met, allow everyone to call a `withdraw()` function
        openForWithdraw = true;
      }
    }
  }



  //if the `threshold` was not met, allow everyone to call a `withdraw()` function


 // Add a `withdraw()` function to let users withdraw their balance

function withdraw() public notCompleted  {
    if(openForWithdraw == true){



    // check if the user has balance to withdraw
    // require(balances[msg.sender] > 0, "You don't have balance to withdraw");

    // reset the balance of the user
    // balances[msg.sender] = 0;

    // Transfer balance back to the user
     msg.sender.call{value: balances[msg.sender]}("");

    }else{
      return;
    }

  }


  
  //Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
function timeLeft() public view returns (uint256 timeleft) {
    if( block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }




  // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        emit Received(msg.sender, msg.value);
      Staker.stake();
    }

}
