pragma solidity =0.6.6;

import "./UniswapV2Router.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract RouterController is Ownable {

    address public dexController;

    function createRouter(address _factory, address _weth) public returns (address) {
        UniswapV2Router router = new UniswapV2Router(_factory, _weth);
        return address(router);
    }

    function setDexController(address _dexController) public onlyOwner {
        dexController = _dexController;
    }
}
