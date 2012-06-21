module Magtek

  def self.available_devices
    usb = LIBUSB::Context.new
    usb.devices.select { |d| d.idVendor == 0x0801 }.map { |d| [ d.idProduct, d.product ] }
  end

end