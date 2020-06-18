module Magtek

  class CardReader

    # number of bytes expected from the reader on a swipe
    MAXBUFLEN = 337
    
    def initialize(product_id = nil)
      product_id = Magtek.available_devices.first unless product_id
      @usb = LIBUSB::Context.new
      @device = @usb.devices(:idVendor => Magtek.vendors, :idProduct => product_id).first
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
      buffer, buffer_length, successful = "", 0, true # initial assumptions
      timeout = options[:timeout] || 5000
      # allow loose buffer length checking, but default to original to ensure backward compatibility
      required_buffer_length = options[:required_buffer_length] || MAXBUFLEN

      begin
        started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        buffer = @handle.interrupt_transfer({ endpoint: @endpoint, dataIn: MAXBUFLEN, timeout: timeout})
        
        # skip over the bogus stuff from the brush sidewinder
        while buffer.bytes == [96, 13, 0, 16] do
          current_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          if (current_at - started_at) * 1000 > timeout
            fail "error TRANSFER_TIMED_OUT"
          end
          buffer = @handle.interrupt_transfer({ endpoint: @endpoint, dataIn: MAXBUFLEN, timeout: timeout})
        end
        
        buffer_length = buffer.length
      rescue => e
        #puts "magtek_card_reader - problem #{e}"
        @handle.reset_device unless e.message == "error TRANSFER_TIMED_OUT"
        successful = false
      end

      if successful 
        if required_buffer_length > 0 && buffer_length != required_buffer_length
          successful = false
        else
          match = /B([0-9]{16})\^(.*)\^([0-9]{2})([0-9]{2})/.match(buffer)
          if match
            number, name, exp_year, exp_month = match.captures
          else
            successful = false
          end
        end
      end

      return false if !successful
      return [true, number, name, exp_year, exp_month]
    end
  
  end

end