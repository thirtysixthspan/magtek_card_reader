module Magtek
  MAGTEK = 0x0801
  BRUSHIND = 0xC256

  def self.available_devices
    usb = LIBUSB::Context.new
    magtek = usb.devices.select { |d| vendors.include?(d.idVendor) }.map { |d| [ d.idProduct, d.product ] }
  end

  def self.vendors
    [ MAGTEK, BRUSHIND ]
  end
end