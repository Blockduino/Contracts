/*
 * Blockduino core contract.
 *
 * Copyright (C) 2018, Visible Energy Inc. and the Blockduino contributors.
 *
 */

pragma solidity ^0.4.24;

contract Blockduino {
	// Blockduino device
	struct Device {	// data structure for devices
		address id;			// BD ethereum address
		address owner;		// contract address owning the device
		bool restricted;	// transactions to device restricted to owner
		bytes32	mac;		// BD MAC address
	}

	address public owner;	// that would be our account deploying the contract

	mapping (address => Device) devices;	// all registered onboarded devices
	address[] public deviceAddresses;		// used to export the devices addresses
	// TODO: make the array private and of size [2**64]? that is address[2**64] -- change way using from .push to [x]

	event NewDevice(address indexed owner, address id);

	/*--*/
    struct Request { // data structure for each request
        address requester; 	// the address of the requester
        uint fee; 			// the amount of wei the requester pays for the request
        address callbackAddr; // the address of the contract to call for delivering response
        bytes4 callbackFID; // the specification of the callback function
        address device;	// device the request is directed to
    }

	int public constant FAIL_FLAG = -2 ** 250;
    uint public GAS_PRICE = 5 * 10**10;
    uint public MIN_FEE = 30000 * GAS_PRICE; // minimum fee required for the requester to pay such that SGX could call deliver() to send a response
    uint64 public requestCnt;
    uint64 public unrespondedCnt;
    Request[2**64] public requests;

    bytes4 constant TC_CALLBACK_FID = bytes4(sha3("response(uint64,uint64,bytes32)"));

	/* ------------------------------------------------------------- */

    modifier onlyByContractOwner() {	// only by contract owner
        require(msg.sender == owner, "Sender not authorized.");
        _;
    }

    /*
     * Convert a string to bytes32 for internal storage.
     */
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    	//bytes memory tempEmptyStringTest = bytes(source);
    	//if (tempEmptyStringTest.length == 0) {
    	// TODO: test the change
    	if ((bytes)(source).length == 0) {
        	return 0x0;
    	}
    	assembly { result := mload(add(source, 32)) }
    }

    /*
     * Check if an address is a contract.
     */
	function isContract(address addr) private view returns (bool) {
	  uint size;
	  assembly { size := extcodesize(addr) }
	  return size > 0;
	}

	/* ------------------------------------------------------------- */

	/*
	 * Contract constructor.
	 */
	constructor() public {
		owner = msg.sender;	// that would be our account deploying the contract
		requestCnt = 1;		// start with 1 because 0 is used to indicate an invalid request
		requests[0].requester = msg.sender;
	}

	// fallback to receive ether
	function () public {}

	/*
	 * Add a new device to the table of registered devices.
	 */
	function addDevice(				// Blockduino
		address _id, 				// public ethereum address
		bool _restricted,			// permission flag
		string _mac_s, 				// MAC address or unique board id
		string _activaction_key_s	// activation key
	) external {
		bytes32 _activaction_key = stringToBytes32(_activaction_key_s);
		// check the _activaction_key is not empty
		require(_activaction_key.length > 0, "Activation key empty.");
		// TODO: actual key validity check

		// check if the device hae not been registered already
		require(devices[_id].owner == address(0), "Device already registered.");

		// create a new device owned by the sender
		bytes32 _mac = stringToBytes32(_mac_s);
		Device memory newDevice = Device({id: _id, owner: msg.sender, mac: _mac, restricted: _restricted});
		devices[_id] = newDevice;
		deviceAddresses.push(newDevice.id);

		emit NewDevice(msg.sender, _id);
	}

	/*
	 * Functions to access registered devices.
	 */
	 function deviceAddressesCount() external constant returns (uint) {
	 	return deviceAddresses.length;
	 }

	 function getDeviceAddress(uint _index) external constant returns (address) {
	 	return deviceAddresses[_index];
	 }

	 function getDevice(address _addr) external constant returns (address, address, bool, bytes32) {
		require(devices[_addr].owner != address(0), "Device not registered or deleted.");

	 	return (devices[_addr].id,  devices[_addr].owner, devices[_addr].restricted, devices[_addr].mac);
	 }

	 function removeDevice(address _addr) external onlyByContractOwner() returns (address) {
	 	require(devices[_addr].owner != address(0), "Device not registered or deleted.");

	 	// in case we allow the device owner to remove the device:
	 	// remove onlyByContractOwner() and add:
	 	// require(devices[_addr].owner == msg.sender, "Only the owner can remove a device.");

	 	// set all fields to 0 - more of a disable than a remove (change the function name?)
	 	devices[_addr].owner = address(0);
	 	devices[_addr].id = address(0);
	 	delete devices[_addr].mac;
	 	return _addr;
	 }

 	/* ------------------------------------------------------------- */

    // event to log the application request
	event RPCRequest(uint64 requestID, uint8 method, address indexed device, uint8[2] paramsIntegers, bytes32 paramsBytes);

	/*
	 * Propagate an RPC request received from the Blockduino SDK.
	 *
	 *  @callbackAddr the address of the contract issuing the request, used in the response.
	 *  @_method the RPC method number of the request to send to the Blockduino board.
	 *  @_ device the Blockduino device Ethereum address
	 *  @_paramsIntegers the integer array data required in the RPC.
	 *  @_paramsBytes the bytes array data required in the RPC.
	 */
 	function request(address callbackAddr, bytes4 callbackFID, uint8 _method, address _device, uint8[2] _paramsIntegers, bytes32 _paramsBytes) public payable returns (int) {
 		uint64 requestID = requestCnt;

 		// if the ether sent by the application contract is below 
 		// the minimum fee refund the sender and exit
 		/* DEBUG: disabled
 		if (msg.value < MIN_FEE) {
            if (!msg.sender.call.value(msg.value)()) {
                revert();
            }
            return FAIL_FLAG;
        }
        */

		// record the request in internal array data structure
		requestCnt++;
        requests[requestID].requester = msg.sender;
        requests[requestID].fee = msg.value;
        requests[requestID].callbackAddr = callbackAddr;
        requests[requestID].callbackFID = callbackFID;
        requests[requestID].device = _device;

        // log the request to be picked up by the Blockduino or relay server
 		emit RPCRequest(requestID, _method, _device, _paramsIntegers, _paramsBytes);

 		// return a unique request id
 		return requestID;
 	}

 	/*
 	 * After sending the RPC request to a Blockduino board that generate a response the Blockduino or the relay server
 	 * sends the response in a transaction calling this function.
 	 *
 	 * 
 	 */
 	function response(uint64 requestID, uint64 error, bytes32 respData) public {
 		if (msg.sender != requests[requestID].device ||
 			requests[requestID].requester == address(0)) {
 			// if the response is not delivered by the same device  account or the
            // request has already been responded to, discard the response.
 			return;
 		}

        uint fee = requests[requestID].fee;
        // TODO: need to deal with fees in general and account for any additional fees for us

        uint callbackGas = (fee - MIN_FEE) / tx.gasprice; // gas left for the callback function
        if (callbackGas > gasleft() - 5000) {
            callbackGas = gasleft() - 5000;
        }

        // call the callback function in the application contract
        requests[requestID].callbackAddr.call.gas(callbackGas)(requests[requestID].callbackFID, error, respData); 
 		requests[requestID].requester = address(0);	// mark the request as responded
 	}

}
