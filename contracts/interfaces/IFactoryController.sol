pragma solidity =0.6.6;

interface IFactoryController {
    function createFactory(address _feeToSetter) external returns(address);
}
