module Magtek

  class CardReader

    def initialize(product_id = nil)
      product_id = Magtek.available_devices.first unless product_id
      @usb = LIBUSB::Context.new
      @device = @usb.devices(:idVendor => Magtek.vendors, :idProduct => product_id).first
      fail "Device not found" unless @device

      # number of bytes expected from the reader on a swipe
      @maxbuflen = 887 # magtek insert card reader
      @maxbuflen = 337 if @device.idProduct == 0xc256 # sidewinder

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
        @handle.detach_kernel_driver(@interface) if @handle.kernel_driver_active?(@interface)
        @handle.set_configuration(1)  
        @handle.claim_interface(@interface)
        @open = true
        return true 
      rescue
        return false
      end
    end
  
    def close
      return true unless @open 
      @handle.release_interface(@interface)
      @handle.close
      @open = false
      true
    end
  
    def read(options)
      if @handle.nil?
        puts "magtek_card_reader - read called while @handle is nil, attempting to open"
        if !open
          puts "magtek_card_reader - unable to open reader when trying to read"
          return false
        end
      end

      buffer, buffer_length, successful = "", 0, true # initial assumptions
      timeout = options[:timeout] || 5000
      # allow loose buffer length checking, but default to original to ensure backward compatibility
      required_buffer_length = options[:required_buffer_length]

      begin
        started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        buffer = @handle.interrupt_transfer({ endpoint: @endpoint, dataIn: @maxbuflen, timeout: timeout})
# puts "magtek_card_reader - initial data #{buffer.bytes}"
        # skip over the bogus stuff from the brush sidewinder
        while buffer.bytes == [96, 13, 0, 16] do
          current_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          if (current_at - started_at) * 1000 > timeout
            fail "error TRANSFER_TIMED_OUT"
          end
          buffer = @handle.interrupt_transfer({ endpoint: @endpoint, dataIn: @maxbuflen, timeout: timeout})
        end
# puts "magtek_card_reader - final data, #{buffer.length}:  #{buffer.bytes}"
# puts "#{buffer}"

        buffer_length = buffer.length
      rescue => e
        puts "magtek_card_reader - problem #{e}"
        @handle.reset_device unless e.message == "error TRANSFER_TIMED_OUT"
        successful = false
      end

      if successful 
        if required_buffer_length > 0 && buffer_length != required_buffer_length
          successful = false
          puts "magtek_card_reader - failed buffer length check #{required_buffer_length}, #{buffer_length}"
        else
          match = /B([0-9]{16})\^(.*?)\^([0-9]{2})([0-9]{2})/.match(buffer)
          if match
            number, name, exp_year, exp_month = match.captures
          else
            successful = false
            puts "magtek_card_reader - failed regex match"
          end
        end
      end

      return false if !successful
      return [true, number, name, exp_year, exp_month, buffer]
    end
  
  end

end