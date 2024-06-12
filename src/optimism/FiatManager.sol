// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

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

contract FiatManager is Ownable, Initializable {
    address whitelistedTakeoverOrigin;
    address tokenProxyAddress;
    address masterMinterAddress;
    address bridgeAddress;

    constructor(address initialOwner) Ownable() {
        require(initialOwner != address(0), "Owner address can not be 0");
        transferOwnership(initialOwner);
    }

    /// @notice Initializes the contract with the given addresses. Also configured the bridge
    ///         as a minter. Note that this contract is expected to have been assigned
    ///         the ownership of the FIAT proxy, implementation, and master minter roles.
    /// @param _bridgeAddress The L2 bridge address.
    /// @param _masterMinterAddress The MasterMinter address.
    /// @param _tokenProxyAddress The address of the FIAT token proxy.
    function initialize(
        address _bridgeAddress,
        address _masterMinterAddress,
        address _tokenProxyAddress
    ) public onlyOwner initializer {
        require(
            _bridgeAddress != address(0) &&
                _masterMinterAddress != address(0) &&
                _tokenProxyAddress != address(0),
            "Zero address not allowed"
        );
        tokenProxyAddress = _tokenProxyAddress;
        bridgeAddress = _bridgeAddress;
        masterMinterAddress = _masterMinterAddress;
        IMasterMinter(masterMinterAddress).configureController(
            address(this),
            bridgeAddress
        );
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
}
