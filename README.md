Magtek Card Reader
==================

Overview
--------

 This gem provides a wrapper around libusb to facilite reading credit card information from a Magtek Credit Card Reader.

Install
-------
Ubuntu
```
sudo apt-get install libusb-1.0-0-dev

gem install libusb magtek_card_reader

```


Notes
-----

You must have appropraite permissions to the USB file descriptors.

Example
--------
```

require 'magtek_card_reader'

puts Magtek.available_devices

mcr = Magtek::CardReader.new

mcr.open

success, number, name, exp_year, exp_month =  mcr.read(:timeout=>10000)

mcr.close

```


Server
------

 The server is a daemon that collects credit card swipe data from Magtek reader and runs
configured callbacks in order to log the data or pass the data on to another server. 
Credit card data is AES encrypted using a passphrase that must be provided when the 
server is started. This passphrase is only stored in memory. The AES encypted data
is then RSA encrypted using a private/public key pair. Only the public key is stored
on the server permitting only encryption. The double encrypted data is not stored locally
but rather is transmitted over a encrypted SSL connection to another server. The credit
card data can only be decrypted if both the AES passphrase and the private RSA key are
provided. The RSA key and callback parameters are combined with the AES passphrase and
a digital signature is created using a SHA512 hash such that the AES passphrase must 
be provided to use the RSA keys or make any callbacks.

 To setup the server:
- install necessary gems using 'bundle install'
- choose a long AES passphrase
- Generate RSA keys using 'rake generate_keys'
- move conf/private.yaml off of the server to protect encryption
- edit conf/callback.yaml.example providing local and/or remote callback endpoints
- Sign the callbacks using 'rake sign_callbacks'
- run credit_card_server with appropriate permissions to USB file descriptors (e.g., as root)


Acknowledgments 
------

 The Ruby wrapper [libusb](https://github.com/larskanis/libusb)

 The [libusb](http://libusbx.org/) library

 Magtek reader script [https://github.com/aughey/magtek](https://github.com/aughey/magtek)

License
-------
Copyright (c) 2012 Derrick Parkhurst (derrick.parkhurst@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


