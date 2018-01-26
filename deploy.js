const HDWalletprovider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const { interface, bytecode } = require('./compile');

const provider = new HDWalletprovider(
		'add mask man biology naive setup cash mammal fox stumble roof remind',
		'https://rinkeby.infura.io/orDImgKRzwNrVCDrAk5Q'
	);
const web3 = new Web3(provider);

const deploy = async () => {
	const accounts = await web3.eth.getAccounts();
	console.log('Attempting to deploy from acct ', accounts[0]);
	const result = await new web3.eth.Contract(JSON.parse(interface))
		.deploy({data: bytecode, arguments: ['Hi there!']})
		.send({ gas:'1000000', from: accounts[0]});
		console.log('contact deployed to ', result.options.address);
};
deploy();



//AFFJANFLSH18 0xB00366bA6BA0a976B7F3F413BD3cA681fEaE5287
//0xcaeDF07313c8A47ba419DF10982e322A4c9590f9