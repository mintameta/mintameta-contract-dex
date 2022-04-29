pragma solidity =0.6.6;

import "./UniswapV2Factory.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract FactoryController is Ownable {

    address public dexController;

    function createFactory(address _feeToSetter) public returns (address) {
        require(msg.sender == dexController, "invalid caller");
        UniswapV2Factory factory = new UniswapV2Factory(_feeToSetter);
        return address(factory);
    }

    function setDexController(address _dexController) public onlyOwner {
        dexController = _dexController;
    }
}
