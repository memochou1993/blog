---
title: 使用 Solidity 在 Ethereum 區塊鏈實作 Staking 智能合約
permalink: 使用-Solidity-在-Ethereum-區塊鏈實作-Staking-智能合約
date: 2022-05-13 23:17:47
tags: ["區塊鏈", "Ethereum", "Web3", "Solidity", "Smart Contract", "DApp", "Truffle"]
categories: ["區塊鏈", "Ethereum"]
---

## 做法

建立專案。

```BASH
mkdir eth-staking
cd eth-staking
```

使用 `truffle` 指令初始化專案。

```BASH
truffle init
```

建立 `contracts/Staking.sol` 檔。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant INITIAL_SUPPLY = 100000000;
    uint256 public rewardRate = 100;

    struct Stake {
        uint256 amount;
        uint256 earned;
        uint256 rewardRate;
        uint256 createdAt;
    }

    address[] private stakeholders;
    mapping(address => Stake) private stakes;

    constructor() ERC20("My Token", "MTK") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function createStake(uint256 _amount)
        public
    {
        require(stakes[msg.sender].amount == 0, "Stake exists.");
        _burn(msg.sender, _amount);
        addStakeholder(msg.sender);
        stakes[msg.sender] = Stake({
            amount: _amount,
            earned: 0,
            rewardRate: rewardRate,
            createdAt: block.timestamp
        });
    }

    function removeStake()
        public
    {
        require(stakes[msg.sender].amount != 0, "Stake does not exists.");
        uint256 _amount = stakes[msg.sender].amount;
        delete stakes[msg.sender];
        removeStakeholder(msg.sender);
        _mint(msg.sender, _amount);
    }

    function stakeOf(address _stakeholder)
        public
        view
        returns (Stake memory)
    {
        return stakes[_stakeholder];
    }

    function totalStakeAmount()
        public
        view
        returns (uint256)
    {
        uint256 _amount = 0;
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            _amount += stakes[stakeholders[i]].amount;
        }
        return _amount;
    }

    function isStakeholder(address _stakeholder)
        public
        view
        returns (bool, uint256)
    {
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            if (_stakeholder == stakeholders[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function calculateReward(address _stakeholder)
        public
        view
        returns (uint256)
    {
        Stake memory _stake = stakes[_stakeholder];
        uint256 _rewardPerSecond = _stake.amount * _stake.rewardRate / 100 / 365 / 86400;
        return (block.timestamp - _stake.createdAt) * _rewardPerSecond - _stake.earned;
    }

    function distributeRewards()
        public
        onlyOwner
    {
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            uint256 _reward = calculateReward(stakeholders[i]);
            stakes[stakeholders[i]].earned += _reward;
            _mint(msg.sender, _reward);
        }
    }

    function setRewardRate(uint256 _rewardRate)
        public
        onlyOwner
    {
        rewardRate = _rewardRate;
    }

    function addStakeholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) {
            stakeholders.push(_stakeholder);
        }
    }

    function removeStakeholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, uint256 i) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[i] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }
}
```

執行部署腳本。

```BASH
truffle migrate --reset
```

## 參考資料

- [HQ20/StakingToken](https://github.com/HQ20/StakingToken)
