pragma solidity =0.6.6;

import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';

contract UniswapV2Factory is IUniswapV2Factory {
    address private feeTo_;
    address private feeToSetter_;
    bytes32 private constant hash_ = keccak256(abi.encodePacked(type(UniswapV2Pair).creationCode));

    mapping(address => mapping(address => address)) private getPair_;
    address[] private allPairs_;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter_ = _feeToSetter;
    }

    function initHashCode() public view override returns(bytes32) {
        return hash_;
    }

    function getPair(address tokenA, address tokenB) public view override returns (address) {
        return getPair_[tokenA][tokenB];
    }

    function allPairs(uint i) public view override returns(address) {
        return allPairs_[i];
    }

    function feeTo() public view override returns(address) {
        return feeTo_;
    }
    function feeToSetter() public view override returns(address) {
        return feeToSetter_;
    }
    function allPairsLength() external override view returns (uint) {
        return allPairs_.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair_[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair_[token0][token1] = pair;
        getPair_[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs_.push(pair);
        emit PairCreated(token0, token1, pair, allPairs_.length);
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter_, 'UniswapV2: FORBIDDEN');
        feeTo_ = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter_, 'UniswapV2: FORBIDDEN');
        feeToSetter_ = _feeToSetter;
    }
}
