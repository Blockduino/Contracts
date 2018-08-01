# Contracts

[Blockduino core contract](https://github.com/Blockduino/Contracts/blob/master/Blockduino.sol)

The main dispatcher for sending instructions and commands to devices off-chain. It is also the centralized management system for Blockduino devices.

[Blockduino SDK](https://github.com/Blockduino/Contracts/blob/master/BlockduinoSDK.sol)

The high-level functions to interact with a Blockduino board and devices connected to it from a Solidity contract.

#### pin naming

Pin numbering mnemonics using BCM mode have mnemonic names used in the GPIO functions.

> This is for the Raspberry PI development system.

| NAME        | PIN |
|------------------|----|
    	D0 | pin 27 (ID_SD) |
    	D1 | pin 28 (ID_SC) |
    	D2 | pin 3 (SDA) |
    	D3 |  pin 5 (SCL) |
    	D4 | pin 7 (GPCLK0) |
    	D5 | pin 29 |
    	D6 | pin 31 |
    	D7 | pin 26 (CE1) |
    	D8 | pin 24 (CE0) |
    	D9 | pin 21 (MISO) |
    	D10 | pin 19 (MOSI) |
    	D11 | pin 23 (SCLK) |
    	D12 | pin 32 (PWM0) |
    	D13 | pin 33 (PWM1) |
    	D14 | pin 8 (TXD) |
    	D15 | pin 10 (RXD) |
    	D16 | pin 36 |
    	D17 | pin 11 |
    	D18 | pin 12 (PWM0) |
    	D19 | pin 35 (MISO) | 
    	D20 | pin 38 (MOSI) |
    	D21 | pin 40 (SCLK) |
    	D22 | pin 15 |
    	D23 | pin 16 |
    	D24 | pin 18 |
    	D25 | pin 22 |
    	D26 | pin 37 |
    	D27 | pin 13 |


```
pinMode(address _device, pin _pin, uint8 _mode, bytes4 callbackFID)
```
Set a GPIO pin mode.

| PARAMETER        | DESCRIPTION                      | TYPE                            |
|------------------|----------------------------------|-------------------------------------
| `_device` | the Blockduino device address          | address |
| `_pin` | affected GPIO pin           | pin |
| `_mode` | new mode | uint |
| `callbackFID` | the callback function ID | bytes4 |


| RETURN     | TYPE  
| -------------------------|-------------------------------------
| new mode | int
