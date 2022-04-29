pragma solidity =0.6.6;

interface IRouterController {
    function createRouter(address _factory, address _weth) external returns(address);
}
