/******************************************************************************
**	@Author:				Thomas Bouder <Tbouder>
**	@Email:					Tbouder@protonmail.com
**	@Date:					Sunday October 3rd 2021
**	@Filename:				deploy.js
******************************************************************************/

async function main() {
    //Compile
    await hre.run("clean");
    await hre.run("compile");

    //Deploy
    this.Contract = await ethers.getContractFactory("rarity_extended_care");
    this.Contract = await this.Contract.deploy();
    console.log("Deployed to:", this.Contract.address);

    await hre.run("verify:verify", {
		address: '0xc066618F5c84D2eB002b99b020364D4CDDE6245D',
		constructorArguments: [],
	});

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });