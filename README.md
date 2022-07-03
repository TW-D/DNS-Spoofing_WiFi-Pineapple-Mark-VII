# keccak256 Bruteforcer

- Title:         keccak256 Bruteforcer
- Target:        keccak256 (SHA-3 family)
- Category:      Bruteforce   

## Description

The keccak256 (SHA-3 family) algorithm computes the hash of an input to a fixed length output. The input can be a variable length string or number, but the result will always be a fixed bytes32 data type. It is a one-way cryptographic hash function, which cannot be decoded in reverse. This consists of 64 characters (letters and numbers) that can be expressed as hexadecimal numbers.

[Hashing Functions In Solidity Using Keccak256](https://medium.com/0xcode/hashing-functions-in-solidity-using-keccak256-70779ea55bb0)

## Tested on

>
> Ubuntu 20.04.4 LTS x86_64
>
> ruby 2.7.0p0
>

## Installation

```bash
apt-get install ruby ruby-dev
gem install keccak256
```

## Usage

```
$ ruby ./keccak256-brute.rb 
Usage: ./keccak256-brute.rb [options]
    -d, --digest DIGEST              The target digest.
    -f, --file FILE                  The file including the passwords.
    -h, --help

Examples:
	 ruby ./keccak256-brute.rb -d b68fe43f0d1a0d7aef123722670be50268e15365401c442f8806ef83b612976b -f ./rockyou.txt
```