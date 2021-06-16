pragma solidity ^0.8.0;
import "prb-math/contracts/PRBMathSD59x18.sol";
import "./Math.sol";

contract LitcoinFactory {
    uint public circulation;
    mapping(address => uint) owner_balances;
    mapping(string => CreatorCoinFactory) ccs;
    mapping(string => bool) ccs_created;
    
    event LitcoinBought(address sender, uint amount);
    event LitcoinSold(address sender, uint amount);

    constructor() {
        circulation = 0;
    }
    
    function getMyBalance() public view returns(uint) {
        return owner_balances[msg.sender];
    }
    
     function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function buyCC(string memory spotifyId, uint litcoin) public payable {
        require(litcoin <= owner_balances[msg.sender], "cannot sell more litcoin than you have");
        if (!ccs_created[spotifyId]) {
            ccs[spotifyId] = new CreatorCoinFactory(spotifyId);
            ccs_created[spotifyId] = true;
        }
        ccs[spotifyId].buy(litcoin);
        circulation -= litcoin;
        owner_balances[msg.sender] -= litcoin;
    }
    
    function sellCC(string memory spotifyId, uint litcoin) public payable {
        require(ccs_created[spotifyId], "that spotifyId does not exist");
        uint amount = ccs[spotifyId].sell(litcoin);
        circulation += amount;
        owner_balances[msg.sender] += amount;
    }
    
    function ccBalance(string memory spotifyId) public view returns(uint) {
        require(ccs_created[spotifyId], "that spotifyId does not exist");
        return ccs[spotifyId].getMyBalance();
    }
    
    function bonding_integral(uint value) private pure returns(uint) {
        return 222*value*Math.sqrt(value);
    }
    
    function sell(uint amount_returned) public payable {
        uint amount = circulation - bonding_integral(address(this).balance - amount_returned);
        require(amount <= owner_balances[msg.sender], "Cannot sell more than you have!");
        require(amount > 0, "Must sell positive amount!");
        owner_balances[msg.sender] -= amount;
        circulation -= amount;
        payable(msg.sender).transfer(amount_returned);
        
        emit LitcoinSold(msg.sender, amount_returned);   
    }
    
    receive() external payable {
        uint total = bonding_integral(address(this).balance);
        uint bought = total - circulation;
        circulation = total;
        owner_balances[msg.sender] += bought;
    
        emit LitcoinBought(msg.sender, msg.value);   
    }
}


contract CreatorCoinFactory {
    uint public litcoin_balance;
    uint public circulation;
    string spotifyId;
    mapping(address => uint) owner_balances;
    
    event CreatorCoinBought(address sender, uint amount);
    event CreatorCoinSold(address sender, uint amount);

    constructor(string memory _spotifyId) {
        litcoin_balance = 0;
        circulation = 0;
        spotifyId = _spotifyId;
    }
    
    function getMyBalance() public view returns(uint) {
        return owner_balances[tx.origin];
    }
    
    function bonding_integral(uint value) private pure returns(uint) {
        return 222*value*Math.sqrt(value);
    }
    
    function sell(uint amount_returned) public payable returns(uint) {
        uint amount = circulation - bonding_integral(litcoin_balance - amount_returned);
        require(amount <= owner_balances[tx.origin], "Cannot sell more than you have!");
        require(amount > 0, "Must sell positive amount!");
        owner_balances[tx.origin] -= amount;
        circulation -= amount;
        return amount_returned;
    }
    
    function buy(uint amount_litcoin) public payable {
        litcoin_balance += amount_litcoin;
        uint total = bonding_integral(litcoin_balance);
        uint bought = total - circulation;
        circulation = total;
        owner_balances[tx.origin] += bought;
    }
}


// contract Litcoin {
//     int public value;
//     address public owner;
    
//     constructor (int _value) {
//         value = _value;
//         owner = tx.origin;
//     }
// }

// contract CreatorCoin {
//     string spotifyId;
//     uint amount;
    
//     constructor (string memory _spotifyId) {
//         spotifyId = _spotifyId;
//     }
// }

// contract LitcoinFactory {
//     int public circulation;
//     // Litcoin[] public coins;
//     // mapping(address => Litcoin[]) owner_wallets;
//     mapping(address => int) owner_balances;
    
//     CreatorCoinFactory[] creatorCoinFactories;
//     mapping(string => CreatorCoinFactory) spotifyIdToFactory;
    
//     event LitcoinBought(address sender, uint amount);

//     constructor() {
//         circulation = 0;
//     }
    
//     function getBalance() public view returns(int) {
//         return owner_balances[msg.sender];
//     }
    
//     function bonding_integral(uint value) private pure returns(int) {
//         return 222*PRBMathSD59x18.pow(int(value), 2)/PRBMathSD59x18.sqrt(int(value));
//     }
    
//     function sell(int amount) public {
//         require(amount <= owner_balances[msg.sender], "Cannot sell more than you have!");
//         require(amount > 0, "Must sell positive amount!");
//         owner_balances[msg.sender] -= amount;
//     }
    
//     // function createCreatorCoinFactory(string spotifyId) public {
//     //     CreatorCoinFactory factory = new CreatorCoinFactory(spotifyId);
//     //     creatorCoinFactories.push(factory);
//     //     spotifyIdToFactory[spotifyId] = factory;
//     // }
    
//     // function buyCreatorCoin(string spotifyId, int amountLitcoin) {
//     //     require(amount <= owner_balances[msg.sender], "Cannot sell more than you have!");   
//     //     spotifyIdToFactory[spotifyId].buy(amount);
//     // }
    
//     receive() external payable {
//         int amount = bonding_integral(address(this).balance) - bonding_integral(address(this).balance - msg.value);
//         circulation += amount;
//         owner_balances[msg.sender] += amount;
        
//         // Litcoin litcoin = new Litcoin(amount);
//         // coins.push(litcoin);
//         // owner_wallets[msg.sender].push(litcoin);
        
//         // emit LitcoinBought(litcoin, address(litcoin));
//         emit LitcoinBought(msg.sender, msg.value);   
//     }
// }


// contract CreatorCoinFactory {
//     string public spotifyId;
//     int circulation;
//     // Litcoin[] wallet;
//     // mapping(address => CreatorCoin[]) owners;
//     mapping(address => int) owner_balances;
    
//     constructor(string memory _spotifyId) {
//         spotifyId = _spotifyId;
//     }
    
//     // function buy(Litcoin coin) public {
        
//     // }
// }