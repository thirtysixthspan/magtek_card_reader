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


