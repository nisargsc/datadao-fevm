require("hardhat-deploy")
require("hardhat-deploy-ethers")

const { networkConfig } = require("../helper-hardhat-config")


const private_key = network.config.accounts[0]
const wallet = new ethers.Wallet(private_key, ethers.provider)

module.exports = async ({ deployments }) => {
    console.log("Wallet Ethereum Address:", wallet.address)

    
    //deploy MembershipNFT
    const MembershipNFT = await ethers.getContractFactory('MembershipNFT', wallet);
    console.log('Deploying MembershipNFT...');
    const membershipNFT = await MembershipNFT.deploy();
    await membershipNFT.deployed()
    console.log('MembershipNFT deployed to:', membershipNFT.address);

    //deploy ResearchDataDAO
    const ResearchDataDAO = await ethers.getContractFactory('ResearchDataDAO', wallet);
    console.log('Deploying ResearchDataDAO...');
    const researchDataDAO = await ResearchDataDAO.deploy([wallet.address],membershipNFT.address);
    await researchDataDAO.deployed()
    console.log('ResearchDataDAO deployed to:', researchDataDAO.address);
}