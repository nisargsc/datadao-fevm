// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./library/DataDAO.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ResearchDataDAO is DataDAO {

    IERC721 public membershipNFT;

    mapping(bytes => mapping(address => uint256)) public fundings;
    mapping(bytes => uint256) public dealStorageFees;
    mapping(bytes => uint64) public dealClient;

    constructor(address[] memory admins, address _membershipNFT) DataDAO(admins) {
        membershipNFT = IERC721(_membershipNFT);
    }

    function joinDAO() public {
        require(membershipNFT.balanceOf(msg.sender) > 0, "You are not the holder of DataDAO NFT");
        addUser(msg.sender, MEMBER_ROLE);
    }

    function createDataSetDealProposal(bytes memory _cidraw, uint _size, uint256 _dealDurationInDays, uint256 _dealStorageFees) public payable {
        require(hasRole(MEMBER_ROLE, msg.sender), "Caller is not a minter");
        createDealProposal(_cidraw, _size, _dealDurationInDays);
        dealStorageFees[_cidraw] = _dealStorageFees;
    }

    function approveOrRejectDataSet(bytes memory _cidraw, DealState _choice) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not a admin");
        approveOrRejectDealProposal(_cidraw, _choice);
    }

    function activateDataSetDealBySP(uint64 _networkDealID) public {
        uint64 client = activateDeal(_networkDealID);
        MarketTypes.GetDealDataCommitmentReturn memory commitmentRet = MarketAPI.getDealDataCommitment(_networkDealID);
        dealClient[commitmentRet.data] = client;
    }

    function withdrawReward(bytes memory _cidraw) public {
        require(getDealState(_cidraw) == DealState.Expired);
        reward(dealClient[_cidraw], dealStorageFees[_cidraw]);
    }
}