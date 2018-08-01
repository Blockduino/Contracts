# Contracts

[Blockduino core contract](https://github.com/Blockduino/Contracts/blob/master/Blockduino.sol)

The main dispatcher for sending instructions and commands to devices off-chain. It is also the centralized management system for Blockduino devices.

[Blockduino SDK](https://github.com/Blockduino/Contracts/blob/master/BlockduinoSDK.sol)

The high-level functions to interact with a Blockduino board and devices connected to it from a Solidity contract.

`pinMode(address _device, pin _pin, uint8 _mode, bytes4 callbackFID)`
Set a GPIO pin mode.

*Parameters*
name | comments
------------ | -------------
  `_device {address}` | the Blockduino device address
  `_pin {pin}` | affected GPIO pin
  `_mode {uint}` | new mode
  `callbackFID {bytes4}` | the callback function ID

*Returns*
name | comments
------------ | -------------
   `{int}` | new mode