// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRarity {
    function adventure(uint _summoner) external;
    function xp(uint _summoner) external view returns (uint);
    function spend_xp(uint _summoner, uint _xp) external;
    function level(uint _summoner) external view returns (uint);
    function level_up(uint _summoner) external;
    function adventurers_log(uint adventurer) external view returns (uint);
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
}

interface IRarityGold {
    function claimable(uint summoner) external view returns (uint amount);
    function claim(uint summoner) external;
}

interface IRarityTheCellar {
    function adventure(uint _summoner) external;
    function scout(uint _summoner) external view returns (uint reward);
    function adventurers_log(uint adventurer) external view returns (uint);
}

contract rarity_care {
    IRarity constant _rm = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    IRarityGold constant _gold = IRarityGold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2);
    IRarityTheCellar constant _cellar = IRarityTheCellar(0x2A0F1cB17680161cF255348dDFDeE94ea8Ca196A);
    string constant public name = "Rarity Extended Care";

    /**
    **  @dev Perform an adventure for an array of summoners
    **  @param _summoners array of tokenID to use
    */
    function adventure(uint[] memory _summoners) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            if (block.timestamp > _rm.adventurers_log(_summoners[i])) {
                _rm.adventure(_summoners[i]);
            }
        }
    }
    
    /**
    **  @dev Send a group of adventurer in the cellar
    **  @param _summoners array of tokenID to use
    **  @param _threshold minimum amount of crafting materials expected
    */
    function adventure_cellar(uint[] memory _summoners, uint _threshold) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            if (block.timestamp > _cellar.adventurers_log(_summoners[i])) {
                uint _reward = _cellar.scout(_summoners[i]);
                if (_reward >= _threshold) {
                    helper_isApprovedOrApprove(_summoners[i]);
                    _cellar.adventure(_summoners[i]);
                }
            }
        }
    }
    
    
    /**
    **  @dev Level up an array of summoners
    **  @param _summoners array of tokenID to use
    */
    function level_up(uint[] memory _summoners) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            uint _level = _rm.level(_summoners[i]);
            uint _xp_required = helper_xp_required(_level);
            uint _xp_available = _rm.xp(_summoners[i]);
            if (_xp_available >= _xp_required) {
                _rm.level_up(_summoners[i]);
            }
        }
    }
    
    /**
    **  @dev Claim gold for an array of summoners
    **  @param _summoners array of tokenID to use
    */
    function claim_gold(uint[] memory _summoners) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            uint _claimable = _gold.claimable(_summoners[i]);
            if (_claimable > 0) {
                helper_isApprovedOrApprove(_summoners[i]);
                _gold.claim(_summoners[i]);
            }
        }
    }
    
    /**
    **  @dev For an array of summoners, try to adventure, then try
    **  to level up, then try to claim gold for each of them.
    **  @param _summoners array of tokenID to use
    **  @param _whatToDo array of bool for what to do [adventure, cellar, levelup, gold]
    **  @param _threshold_cellar minimum amount of crafting materials expected
    */
    function care_of(uint[] memory _summoners, bool[4] memory _whatToDo, uint _threshold_cellar) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            helper_isApprovedOrApprove(_summoners[i]);
            if (_whatToDo[0]) {
                if (block.timestamp > _rm.adventurers_log(_summoners[i])) {
                    _rm.adventure(_summoners[i]);
                }
            }
            if (_whatToDo[1]) {
                if (block.timestamp > _cellar.adventurers_log(_summoners[i])) {
                    uint _reward = _cellar.scout(_summoners[i]);
                    if (_reward >= _threshold_cellar) {
                        _cellar.adventure(_summoners[i]);
                    }
                }
            }
            if (_whatToDo[2]) {
                uint _level = _rm.level(_summoners[i]);
                uint _xp_required = helper_xp_required(_level);
                uint _xp_available = _rm.xp(_summoners[i]);
                if (_xp_available >= _xp_required) {
                    _rm.level_up(_summoners[i]);
                }
            }
            if (_whatToDo[3]) {
                uint _claimable = _gold.claimable(_summoners[i]);
                if (_claimable > 0) {
                    _gold.claim(_summoners[i]);
                }
            }
        }
    }

    /**
    **  @dev Perform an adventure for an array of summoners
    **  @notice UNSAFE FUNCTION. There is no check so if any 
    **  of the adventurer cannot perform the action, the whole tx 
    **  will revert
    **  @param _summoners array of tokenID to use
    */
    function UNSAFE_adventure(uint[] memory _summoners) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            _rm.adventure(_summoners[i]);
        }
    }

    /**
    **  @dev Send a group of adventurer in the cellar
    **  @notice UNSAFE FUNCTION. There is no check so if any 
    **  of the adventurer cannot perform the action, the whole tx 
    **  will revert
    **  @param _summoners array of tokenID to use
    **  @param _threshold minimum amount of crafting materials expected
    */
    function UNSAFE_adventure_cellar(uint[] memory _summoners) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            helper_isApprovedOrApprove(_summoners[i]);
            _cellar.adventure(_summoners[i]);
        }
    }

    /**
    **  @dev Level up an array of summoners
    **  @notice UNSAFE FUNCTION. There is no check so if any 
    **  of the adventurer cannot perform the action, the whole tx 
    **  will revert
    **  @param _summoners array of tokenID to use
    */
    function UNSAFE_level_up(uint[] memory _summoners) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            _rm.level_up(_summoners[i]);
        }
    }
   
    /**
    **  @dev Claim gold for an array of summoners
    **  @notice UNSAFE FUNCTION. There is no check so if any 
    **  of the adventurer cannot perform the action, the whole tx 
    **  will revert
    **  @param _summoners array of tokenID to use
    */
    function UNSAFE_claim_gold(uint[] memory _summoners) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            helper_isApprovedOrApprove(_summoners[i]);
            _gold.claim(_summoners[i]);
        }
    }

    /**
    **  @dev For an array of summoners, try to adventure, then try
    **  to level up, then try to claim gold for each of them.
    **  @notice UNSAFE FUNCTION. There is no check so if any 
    **  of the adventurer cannot perform the action, the whole tx 
    **  will revert
    **  @param _summoners array of tokenID to use
    **  @param _whatToDo array of bool for what to do [adventure, cellar, levelup, gold]
    */
    function UNSAFE_care_of(uint[] memory _summoners, bool[4] memory _whatToDo) external {
        for (uint256 i = 0; i < _summoners.length; i++) {
            helper_isApprovedOrApprove(_summoners[i]);
            if (_whatToDo[0]) {
                _rm.adventure(_summoners[i]);
            }
            if (_whatToDo[1]) {
                _cellar.adventure(_summoners[i]);
            }
            if (_whatToDo[2]) {
                _rm.level_up(_summoners[i]);
            }
            if (_whatToDo[3]) {
                _gold.claim(_summoners[i]);
            }
        }
    }
    
    function helper_xp_required(uint curent_level) public pure returns (uint xp_to_next_level) {
        xp_to_next_level = curent_level * 1000e18;
        for (uint i = 1; i < curent_level; i++) {
            xp_to_next_level += curent_level * 1000e18;
        }
    }
    
    function helper_isApprovedOrApprove(uint _summoner) internal {
        address _approved = _rm.getApproved(_summoner);
        if (_approved != address(this)) {
            _rm.approve(address(this), _summoner);
        }
    }
}
