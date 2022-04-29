pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import "./interfaces/IFactoryController.sol";
import "./interfaces/IRouterController.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./libraries/SafeMath.sol";

contract DexController is Ownable {
    using SafeMath for uint256;

    /* ========== STRUCT ========== */
    struct Dex {
        address factory;
        address router;
        address feeToSetter;
        address creator;
        bytes32 hash;
        uint256 createTime;
        uint256 expire;
        uint256 payAmount;
        string project;
        string subDomain;
        string logo;
        string slogan;
    }

    struct Combo {
        uint256 price;
        uint256 duration;
    }

    mapping(address => Dex) public dexMap;

    mapping(string => bool) public subDomainCheck;

    Dex[] public dexList;
    Combo[] public comboList;

    address public factoryController;
    address public routerController;
    address public weth;
    address public payee;
    uint256 public sale;

    event CreateDex(
        address indexed creator,
        address factory,
        address router,
        address feeSetter,
        string project,
        string subDomain,
        string logo,
        string slogan,
        bytes32 hash,
        uint256 createTime);

    constructor(address _weth, address _payee) public {
        weth = _weth;
        payee = _payee;
        comboList.push(Combo({price : 1e16, duration : 90 days}));
        comboList.push(Combo({price : 1e16, duration : 180 days}));
        comboList.push(Combo({price : 1e16, duration : 360 days}));
    }

    /* ========== VIEW FUNCTION ========== */
    function getDex(address _creator) public view returns (Dex memory dex) {
        return dexMap[_creator];
    }

    function getDexLength() public view returns (uint256) {
        return dexList.length;
    }

    function getComboList() public view returns (Combo[] memory list) {
        if (comboList.length > 0) {
            list = comboList;
        }
        return list;
    }

    /* ========== CORE FUNCTION ========== */
    function createDex(uint256 _comboIndex, address _feeToSetter, string memory _project, string memory _subDomain, string memory _logo, string memory _slogan) public payable {

        require(bytes(_project).length > 0, "invalid length");
        require(bytes(_subDomain).length > 0, "invalid length");
        require(!subDomainCheck[_subDomain], "subDomain in use");
        require(dexMap[msg.sender].creator == address(0), "already create dex");
        require(msg.value == comboList[_comboIndex].price, "not enough money");

        address factory = IFactoryController(factoryController).createFactory(_feeToSetter);
        address router = IRouterController(routerController).createRouter(factory, weth);
        uint256 duration = comboList[_comboIndex].duration;
        Dex storage dex = dexMap[msg.sender];
        dex.factory = factory;
        dex.router = router;
        dex.hash = IUniswapV2Factory(factory).initHashCode();
        dex.feeToSetter = _feeToSetter;
        dex.creator = msg.sender;
        dex.createTime = block.timestamp;
        dex.payAmount = msg.value;
        dex.subDomain = _subDomain;
        dex.logo = _logo;
        dex.slogan = _slogan;
        dex.expire = dex.expire.add(duration).add(block.timestamp);
        dexList.push(dex);
        sale = sale.add(msg.value);
        subDomainCheck[_subDomain] = true;

        payable(payee).transfer(msg.value);

        emit CreateDex(msg.sender, factory, router, _feeToSetter, _project, _subDomain, _logo, _slogan, dex.hash, dex.createTime);

    }

    function renewal(uint256 _comboIndex, address _creator) public payable {
        require(dexMap[_creator].creator != address(0), "creator is not exist");
        uint256 price = comboList[_comboIndex].price;
        uint256 duration = comboList[_comboIndex].duration;
        require(msg.value == price, "not enough money");
        dexMap[_creator].payAmount = dexMap[_creator].payAmount.add(msg.value);
        dexMap[_creator].expire = dexMap[_creator].expire > block.timestamp ? dexMap[_creator].expire.add(duration) : block.timestamp.add(duration);
        sale = sale.add(msg.value);
        payable(payee).transfer(msg.value);
    }

    /* ========== GOVERNANCE ========== */
    function setFactoryController(address _factoryController) public onlyOwner {
        require(_factoryController != address(0), "invalid address");
        factoryController = _factoryController;
    }

    function setRouterController(address _routerController) public onlyOwner {
        require(_routerController != address(0), "invalid address");
        routerController = _routerController;
    }

    function setPayee(address _payee) public onlyOwner {
        require(_payee != address(0), "invalid address");
        payee = _payee;
    }

    function setCombo(uint256 _comboIndex, uint256 _price, uint256 _duration) public onlyOwner {
        comboList[_comboIndex].price = _price;
        comboList[_comboIndex].duration = _duration;
    }

}
