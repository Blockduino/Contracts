# Contracts

### Index
[Blockduino core contract](https://github.com/Blockduino/Contracts/blob/master/Blockduino.sol)

The main dispatcher for sending instructions and commands to devices off-chain. It is also the centralized management system for Blockduino devices.

`Ropsten address: 0xC859B2826d7c39a5CcA1F651c053523b45AbA64f`

[Getting Started with Blockduino](https://github.com/Blockduino/Blockduino/blob/master/Getting Started.md)

[Blockduino SDK](https://github.com/Blockduino/Contracts/blob/master/BlockduinoSDK.sol)

The high-level functions to interact with a Blockduino board and devices connected to it from a Solidity contract.

* [General Purpose IO Pins](#gpio-functions)
* [Serial Port and USB](#serial-port-and-usb)
* [I2C Bus](#i2c-bus)
* [DAC Pins](#dac-pins)
* [SPI Interface](#spi-interface)
* [CAN Bus](#can-bus)
* [Triggers](#triggers)
* [Pins Naming](#pins-naming)

### GPIO Functions

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
| request ID | int

```
digitalRead(address _device, pin _pin, bytes4 callbackFID)
```
Read the state of a digital pin.

| PARAMETER        | DESCRIPTION                      | TYPE                            |
|------------------|----------------------------------|-------------------------------------
| `_device` | the Blockduino device address          | address |
| `_pin` |  GPIO pin to read          | pin |
| `callbackFID` | the callback function ID | bytes4 |

| RETURN     | TYPE  
| -------------------------|-------------------------------------
| request ID | int

```
digitalWrite(address _device, pin _pin, uint8 _state, bytes4 callbackFID)
```
Write the state of a digital pin.

| PARAMETER        | DESCRIPTION                      | TYPE                            |
|------------------|----------------------------------|-------------------------------------
| `_device` | the Blockduino device address          | address |
| `_pin` |  GPIO pin to write          | pin |
| `_state` | new state | uint8 |
| `callbackFID` | the callback function ID | bytes4 |

| RETURN     | TYPE  
| -------------------------|-------------------------------------
| request ID | int

```
pinToggle(address _device, pin _pin, bytes4 callbackFID)
```
Toggle the state of a digital pin.

| PARAMETER        | DESCRIPTION                      | TYPE                            |
|------------------|----------------------------------|-------------------------------------
| `_device` | the Blockduino device address          | address |
| `_pin` |  GPIO pin to toggle          | pin |
| `callbackFID` | the callback function ID | bytes4 |

| RETURN     | TYPE  
| -------------------------|-------------------------------------
| request ID | int


### Serial Port and USB
```
serialRead(address _device, uint8 _maxbytes, bytes4 callbackFID)
```
Read a single bytes32 buffer from the serial port.

| PARAMETER        | DESCRIPTION                      | TYPE                            |
|------------------|----------------------------------|-------------------------------------
| `_device` | the Blockduino device address          | address |
| `_maxbytes` |  number of bytes to read (<= 32)        | uint8 |
| `callbackFID` | the callback function ID | bytes4 |

| RETURN     | TYPE  
| -------------------------|-------------------------------------
| request ID | int

```
serialWrite(address _device, uint8 _numbytes, bytes32 _buffer, bytes4 callbackFID)
```
Write bytes from a single bytes32 buffer to the serial port.

| PARAMETER        | DESCRIPTION                      | TYPE                            |
|------------------|----------------------------------|-------------------------------------
| `_device` | the Blockduino device address          | address |
| `_maxbytes` |  number of bytes to write (<= 32)        | uint8 |
| `_buffer` |  buffer to write         | bytes32 |
| `callbackFID` | the callback function ID | bytes4 |

| RETURN     | TYPE  
| -------------------------|-------------------------------------
| request ID | int

### I2C Bus

### DAC Pins

### SPI Interface

### CAN Bus

### Triggers
Triggers are based on interrupts or values of GPIO pins and other interfaces. Once a trigger is set, a one-way transaction to the application smart-contract is initiated by the board upon trigger occurence. 

> Since triggers needs gas, there are limits to the number of triggers a Blockduino can handle. A portion of the funds in the Blockduino wallet are dedicated to triggers.


### Pins Naming

Pins have mnemonic names used in the GPIO functions.

> This is for the Raspberry PI development system using BCM mode.

| NAME        | PIN |
|------------------|----|
|    	D0 | pin 27 (ID_SD) |
|    	D1 | pin 28 (ID_SC) |
|    	D2 | pin 3 (SDA) |
|    	D3 |  pin 5 (SCL) |
|    	D4 | pin 7 (GPCLK0) |
|    	D5 | pin 29 |
|    	D6 | pin 31 |
|    	D7 | pin 26 (CE1) |
|    	D8 | pin 24 (CE0) |
|    	D9 | pin 21 (MISO) |
|    	D10 | pin 19 (MOSI) |
|    	D11 | pin 23 (SCLK) |
|    	D12 | pin 32 (PWM0) |
|    	D13 | pin 33 (PWM1) |
|    	D14 | pin 8 (TXD) |
|    	D15 | pin 10 (RXD) |
|    	D16 | pin 36 |
|    	D17 | pin 11 |
|    	D18 | pin 12 (PWM0) |
|    	D19 | pin 35 (MISO) | 
|    	D20 | pin 38 (MOSI) |
|    	D21 | pin 40 (SCLK) |
|    	D22 | pin 15 |
|    	D23 | pin 16 |
|    	D24 | pin 18 |
|    	D25 | pin 22 |
|    	D26 | pin 37 |
|    	D27 | pin 13 |