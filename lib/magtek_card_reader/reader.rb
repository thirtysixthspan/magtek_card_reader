module Magtek

  class CardReader
    
    def initialize(product_id = nil)
      product_id = Magtek.available_devices.first unless product_id
      @usb = LIBUSB::Context.new
      @device = @usb.devices(:idVendor => 0x0801, :idProduct => product_id).first
      fail "Device not found" unless @device
      @interface = @device.interfaces.first
      fail "Interface not found" unless @interface
      @endpoint = @interface.endpoints.first
      fail "Endpoint not found" unless @endpoint
      @open = false
    end
  
    def open
      close
      begin 
        @handle = @device.open
        @handle.detach_kernel_driver(0) if @handle.kernel_driver_active?(0)
        @handle.set_configuration(1)  
        @handle.claim_interface(0) 
        @open = true
        return true 
      rescue
        return false
      end
    end
  
    def close
      return true unless @open 
      @handle.release_interface(0)
      @handle.close 
      true
    end
  
    def read(options)
      timeout = options[:timeout] || 5000
  
      @interrupt_transfer = LIBUSB::InterruptTransfer.new
      @interrupt_transfer.dev_handle = @handle
      @interrupt_transfer.endpoint = @endpoint
      @interrupt_transfer.alloc_buffer(337)
      @interrupt_transfer.timeout = timeout
      begin
        @interrupt_transfer.submit_and_wait!
      rescue => e
        @handle.reset_device unless e.message == "error TRANSFER_TIMED_OUT"
        return false
      end
      return false unless @interrupt_transfer.actual_length==337
  
      match = /B([0-9]{16})\^(.*)\^([0-9]{2})([0-9]{2})/.match(@interrupt_transfer.actual_buffer)
      return false unless match
  
      number, name, exp_year, exp_month = match.captures
      return [true, number, name, exp_year, exp_month]
    end
  
  end

end