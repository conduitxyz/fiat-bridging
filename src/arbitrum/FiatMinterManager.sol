// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IArbToken} from "./IArbToken.sol";

interface IFiatProxy {
    function changeAdmin(address newAdmin) external;
}

interface IFiatImpl {
    function transferOwnership(address newOwner) external;
}

interface IMasterMinter {
    function configureController(address, address) external;

    function removeController(address) external;

    function configureMinter(uint256) external;

    function removeMinter() external returns (bool);
}

/// @notice The parts of the FiatToken interface we need.
interface IPartialFiat is IERC20 {
    function mint(address _to, uint256 _amount) external;

    function burn(uint256 _amount) external;
}

contract FiatManager is Ownable, Initializable, IArbToken {
    address whitelistedTakeoverOrigin;
    address tokenProxyAddress;
    address masterMinterAddress;
    address l2CustomGateway;
    address l1FiatAddress;

    constructor(address initialOwner) Ownable() {
        require(initialOwner != address(0), "Owner address can not be 0");
        transferOwnership(initialOwner);
    }

    /// @notice Initializes the contract with the given addresses. Also configured the bridge
    ///         as a minter. Note that this contract is expected to have been assigned
    ///         the ownership of the FIAT proxy, implementation, and master minter roles.
    /// @param _l2CustomGateway The L2 custom gateway address.
    /// @param _masterMinterAddress The MasterMinter address.
    /// @param _tokenProxyAddress The address of the FIAT token proxy.
    function initialize(
        address _l2CustomGateway,
        address _masterMinterAddress,
        address _tokenProxyAddress,
        address _l1FiatAddress
    ) public onlyOwner initializer {
        require(
            _l2CustomGateway != address(0) &&
                _masterMinterAddress != address(0) &&
                _tokenProxyAddress != address(0),
            "Zero address not allowed"
        );
        tokenProxyAddress = _tokenProxyAddress;
        l2CustomGateway = _l2CustomGateway;
        masterMinterAddress = _masterMinterAddress;
        IMasterMinter(masterMinterAddress).configureController(
            address(this),
            address(this)
        );
        l1FiatAddress = _l1FiatAddress;
        IMasterMinter(masterMinterAddress).configureMinter(type(uint256).max);
    }

    /// @notice Allows the given address to take over the FIAT roles. Note that this
    ///         function can only be called once.
    /// @param _whitelistedTakeoverOrigin Address to be whitelisted.
    function allowTakeover(
        address _whitelistedTakeoverOrigin
    ) public onlyOwner {
        require(
            whitelistedTakeoverOrigin == address(0),
            "Whitelist address already set"
        );
        whitelistedTakeoverOrigin = _whitelistedTakeoverOrigin;
    }

    /// @notice Transfers FIAT roles to a pre-whitelisted account and removes minting
    ///         privileges from the bridge.
    /// @param owner Address to transfer the roles to.
    function transferFIATRoles(address owner) external {
        require(
            msg.sender == whitelistedTakeoverOrigin,
            "Unauthorized transfer"
        );
        require(
            owner != address(0),
            "Can not transfer ownership to the zero address"
        );

        // Change proxy admin
        IFiatProxy(tokenProxyAddress).changeAdmin(owner);

        // remove our minter (i.e. the bridge)
        IMasterMinter(masterMinterAddress).removeMinter();

        // Take our controller role away
        IMasterMinter(masterMinterAddress).removeController(address(this));

        // Transfer implementation owner
        IFiatImpl(tokenProxyAddress).transferOwnership(owner);
    }

    /* -------------------------------------------------------------------------- */
    /*                             Arb Token Functions                            */
    /* -------------------------------------------------------------------------- */
    /// @info Functions allow contract to be a light wrapper for the L1 token.
    /// @notice User needs to approve the contract to spend FIAT first.
    function bridgeBurn(address account, uint256 amount) external override {
        require(msg.sender == l2CustomGateway, "Only the bridge can burn");

        IERC20(tokenProxyAddress).transfer(account, amount);
        IPartialFiat(tokenProxyAddress).burn(amount);
    }

    function bridgeMint(address account, uint256 amount) external override {
        require(msg.sender == l2CustomGateway, "Only the bridge can mint");
        IPartialFiat(tokenProxyAddress).mint(account, amount);
    }

    function l1Address() external view override returns (address) {
        return l1FiatAddress;
    }
}
