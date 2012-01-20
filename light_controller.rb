require 'usb'

class LightController
	VENDOR_ID = 0x0fc5
    PRODUCT_ID = 0xb080
    INTERFACE_ID = 0
    
    COLOR_KEY_GREEN = "GREEN"
    COLOR_KEY_RED = "RED"
    COLOR_KEY_YELLOW = "YELLOW"
    COLOR_KEY_OFF = "OFF"
	
	LIGHT_MAP = {
    	COLOR_KEY_GREEN => "\x01",
    	COLOR_KEY_RED => "\x02",
    	COLOR_KEY_YELLOW => "\x04",
    	COLOR_KEY_OFF => "\x00"
	}
	
	# switch light to red
	def red
		light COLOR_KEY_RED
	end
	
	# switch light to yellow
	def yellow 
		light COLOR_KEY_YELLOW
	end
	
	# switch light to green
	def green
		light COLOR_KEY_GREEN
	end
	
	# switch light off
	def off
		light COLOR_KEY_OFF
	end
	
	# switch light on based on color key value
	def light(color_key)
		data = LIGHT_MAP[color_key]

		device = USB.devices.find {|device| device.idVendor == VENDOR_ID && device.idProduct == PRODUCT_ID}
		handle = device.usb_open
    	handle.usb_control_msg(0x21, 0x09, 0x0635, 0x000, "\x65\x0C#{data}\xFF\x00\x00\x00\x00", 0)

    	handle.usb_close
    	handle = nil
 	
    end
    

end