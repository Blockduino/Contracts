/*
 * Copyright (C) 2018, Visible Energy Inc. and the Blockduino contributors.
 */
pragma solidity ^0.4.24;

/// @title Blockduino SDK 
/// @notice The contract with the functions to interact with Blockduino boards
/// @dev Communication off-chain with the board is through the Blockduino core contract

// declarations of public core contract functions used by the SDK
contract Blockduino {
	function request(address callbackAddr, bytes4 callbackFID, uint8 _method, address _device, uint8[2] _paramsIntegers, bytes32 _paramsBytes) public payable returns (int);
	function getDevice(address _addr) external constant returns (address, address, bool, bytes32);
}

contract usingBlockduinoSDK {
	address public contract_owner;
    Blockduino public CONTRACT;

    // -- START ------ RaspberryHAL
    //
    /// @devel pin numbering mnemonics using BCM mode 
    /// symbols will have the numeric value of the mnemonic
    enum pin {
    	D0, // pin 27 (ID_SD)
    	D1, // pin 28 (ID_SC)
    	D2, // pin 3 (SDA)
    	D3, // pin 5 (SCL)
    	D4, // pin 7 (GPCLK0)
    	D5, // pin 29
    	D6, // pin 31
    	D7, // pin 26 (CE1)
    	D8, // pin 24 (CE0)
    	D9, // pin 21 (MISO)
    	D10, // pin 19 (MOSI)
    	D11, // pin 23 (SCLK)
    	D12, // pin 32 (PWM0)
    	D13, // pin 33 (PWM1)
    	D14, // pin 8 (TXD)
    	D15, // pin 10 (RXD)
    	D16, // pin 36
    	D17, // pin 11
    	D18, // pin 12 (PWM0)
    	D19, // pin 35 (MISO)
    	D20, // pin 38 (MOSI)
    	D21, // pin 40 (SCLK)
    	D22, // pin 15
    	D23, // pin 16
    	D24, // pin 18
    	D25, // pin 22
    	D26, // pin 37
    	D27  // pin 13
    }
    
    /* digital pins modes */
    uint8 constant INPUT = 1;
    uint8 constant OUTPUT = 2;
    uint8 constant INPUT_PULLUP = 3;
    uint8 constant INPUT_PULLDOWN = 4;
    /* digital pins state values */
    uint8 constant LOW = 0;
    uint8  HIGH = 1;
    
    //
    // -- END ------ RaspberryHAL
    
    /// @dev This contract is never deployed by itself but is always the base contract of an application
    /// @param bcCont the Blockduino core contract address
    /// @param owner the owner of the derived contract
	constructor (address bcCont, address owner) public {
		contract_owner = owner;
		CONTRACT = Blockduino(bcCont);
	}

	// RPC method names and numbering
	uint8 constant BD_pinMode = 1;
	uint8 constant BD_digitalRead = 2;
	uint8 constant BD_digitalWrite = 3;
	uint8 constant BD_pinToggle = 4;
	uint8 constant BD_serialRead = 5;
	uint8 constant BD_serialWrite = 6;

    // minimum gas required for a RPC
   	uint constant MIN_GAS = 30000 + 20000;
    uint constant GAS_PRICE = 4 * 10 ** 10;
    uint constant BD_MINFEE = MIN_GAS * GAS_PRICE;

    // the FID of a null callback
    bytes4 constant CB_NULL = '0x0';

    /// @dev modifier to restrict use of a function to the device owner
    /// @param _addr is the Blockduino device address
    modifier onlyByDeviceOwner(address _addr) {
        address device_owner;
        bool restricted;
        
        // obtain device details from the core contract
 		(,device_owner, restricted,) = CONTRACT.getDevice(_addr);

 		if (restricted) {
	    	require(device_owner == msg.sender, "Device registered to different owner");
 		}
    	_;
    }

    // event used for tracing the SDK request to the Blockduino contract
	event BlockduinoSDK(uint8 _method, address _device, uint8[2] _paramsIntegers, bytes32 _paramsBytes);

 	/// @dev propagate a RPC request to the core contract and log it for tracing
	function request(bytes4 callbackFID, uint8 _method, address _device, uint8[2] _paramsIntegers, bytes32 _paramsBytes) private returns(int) {
		int reply = 1;

		// send a transaction to the Blockduino core contract calling the Blockduino.request() function
        reply = CONTRACT.request(this, callbackFID, _method, _device, _paramsIntegers, _paramsBytes);

        if (reply <= 0) {
 			// let the caller issue a refund when appropriate
            return reply;
        }
        // TODO: save and use the reply that is actually a request ID for successful requests 

        // log the SDK call
		emit BlockduinoSDK(_method, _device, _paramsIntegers, _paramsBytes);
		return reply;
	}
    
	/// @dev Set a GPIO pin mode
	/// @param _device the Blockduino device address
	/// @param _pin affected GPIO pin
	/// @param _mode new mode
	/// @param callbackFID the callback function ID
	function pinMode(address _device, pin _pin, uint8 _mode, bytes4 callbackFID) public payable onlyByDeviceOwner(_device) returns(int) {
		bytes32 rpc_params_bytes = '0x0';
		uint8[2] memory rpc_params_int;
		int reply;
		
		rpc_params_int[1] = _mode;
		rpc_params_int[0] = uint8(_pin);

		// call the Blockduino contract with the RPC request
        reply = request(callbackFID, BD_pinMode, _device, rpc_params_int, rpc_params_bytes);
	    return reply;
	}

	/// @dev Read the state of a digital pin
	/// @param _device the Blockduino device address
	/// @param _pin GPIO pin to read
	/// @param callbackFID the callback function ID	 
	function digitalRead(address _device, pin _pin, bytes4 callbackFID) public payable onlyByDeviceOwner(_device) returns(int) {
		bytes32 rpc_params_bytes = '0x0';
		uint8[2] memory rpc_params_int;
		int reply;

		rpc_params_int[0] = uint8(_pin);

		// call the Blockduino contract with the RPC request
		reply = request(callbackFID, BD_digitalRead, _device, rpc_params_int, rpc_params_bytes);	
		return reply;
	}

	/// @dev  Write the state of a digital pin
	/// @param _device the Blockduino device address
	/// @param _pin GPIO pin to write
	/// @param _state the new state for the pin
	/// @param callbackFID the callback function ID	 
	function digitalWrite(address _device, pin _pin, uint8 _state, bytes4 callbackFID) public payable onlyByDeviceOwner(_device) returns(int) {
		bytes32 rpc_params_bytes = '0x0';
		uint8[2] memory rpc_params_int;
		int reply;		

		rpc_params_int[0] = uint8(_pin);
		rpc_params_int[1] = _state;

		// call the Blockduino contract with the RPC request
		reply = request(callbackFID, BD_digitalWrite, _device, rpc_params_int, rpc_params_bytes);	
		return reply;
	}

	/// @dev Toggle the state of a digital pin
	/// @param _device the Blockduino device address
	/// @param _pin GPIO pin to toggle
	/// @param callbackFID the callback function ID	
	function pinToggle(address _device, pin _pin, bytes4 callbackFID) public payable onlyByDeviceOwner(_device) returns(int) {
		bytes32 rpc_params_bytes = '0x0';
		uint8[2] memory rpc_params_int;
		int reply;		

		rpc_params_int[0] = uint8(_pin);

		// call the Blockduino contract with the RPC request
		reply = request(callbackFID, BD_pinToggle, _device, rpc_params_int, rpc_params_bytes);	
		return reply;
	}
	
	/// @dev Read a single bytes32 buffer from the serial port
	/// @param _device the Blockduino device address
	/// @param _maxbytes number of bytes to read
	/// @param callbackFID the callback function ID	
	 function serialRead(address _device, uint8 _maxbytes, bytes4 callbackFID) public payable onlyByDeviceOwner(_device) returns(int) {
 		bytes32 rpc_params_bytes = '0x0';
		uint8[2] memory rpc_params_int;
		int reply;		

		rpc_params_int[0] = uint8(_maxbytes);

		// call the Blockduino contract with the RPC request
		reply = request(callbackFID, BD_serialRead, _device, rpc_params_int, rpc_params_bytes);	
		return reply;       
	 }
	 
	/// @dev Write bytes from a single bytes32 buffer to the serial port
	/// @param _device the Blockduino device address
	/// @param _numbytes number of bytes to write
	/// @param _buffer the buffer to write
	/// @param callbackFID the callback function ID		 
	 function serialWrite(address _device, uint8 _numbytes, bytes32 _buffer, bytes4 callbackFID) public payable onlyByDeviceOwner(_device) returns(int) {
 		bytes32 rpc_params_bytes = _buffer;
		uint8[2] memory rpc_params_int;
		int reply;		

		rpc_params_int[0] = uint8(_numbytes);

		// call the Blockduino contract with the RPC request
		reply = request(callbackFID, BD_serialWrite, _device, rpc_params_int, rpc_params_bytes);	
		return reply;       
	 }
	 	 
}
