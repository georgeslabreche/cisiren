require_relative 'light_controller'

=begin
      International Morse code is composed of five elements:
        1) short mark, dot or 'dit' (·) — 'dot duration' is one unit long
        2) longer mark, dash or 'dah' (–) — three units long
        3) inter-element gap between the dots and dashes within a character — one dot duration or one unit long
        4) short gap (between letters) — three units long
        5) medium gap (between words) — seven units long
=end
class MorseLightThread
  # More code unit length in seconds
  MORSE_CODE_UNIT_LENGTH = 0.1
  
  def initialize(morse_msg, light_key)
  	@lock = Mutex.new  # For thread safety
  	
    @morse_msg = morse_msg
    @light_key = light_key
     
    @light_controller = LightController.new
    
    # Set flag to run the loop
    @running = true
  end
  
  def current_light=(val)
  	@lock.synchronize {
    	@current_light = val
    }
  end
  
  def running
  	@lock.synchronize {
  		@running
  	}
  end
  
  def running=(val)
  	@lock.synchronize {
    	@running = val
    }
  end


  def run

	while running

      		morse_msg_array = @morse_msg.scan(/./)
      		morse_msg_array_idx = 0

      		morse_msg_array.each do |morse_code|

        		if morse_code == '.'
          			# flash a 'di'
          			# short mark, dot or 'dit' (·) — 'dot duration' is one unit long
          			#p "DI " + @light_key
          			@light_controller.light(@light_key)
          			morse_pause 1

          			# inter-element gap between the dots and dashes within a character — one dot duration or one unit long
          			@light_controller.off
          			morse_pause 1

        		elsif morse_code == '-'
          			# flash a 'dah'
          			# longer mark, dash or 'dah' (–) — three units long
          			#p "DAH " + @light_key
          			@light_controller.light(@light_key)
          			morse_pause 3

          			# inter-element gap between the dots and dashes within a character — one dot duration or one unit long
          			@light_controller.off
          			morse_pause 1

        		elsif morse_code == ' '

          			# if it is a whitespace and the next character is also a whitespace
          			# then it means we have reached the end of a word.
          			if(morse_msg_array.at(morse_msg_array_idx + 1) == ' ')
            			# medium gap (between words) — seven units long

            			# It's 7 units long but here we sleep for only 6 units because the
            			# first unit was already executed as an inter-element gap immediately
            			# after the previous 'di' or 'dah'
            			#p "inter-word"
            			@light_controller.light(@light_key)
            			morse_pause 6

          			# if it is a whitespace and the previous character is not a whitespace
          			# then it means we have reached the end of a letter.
          			elsif(morse_msg_array.at(morse_msg_array_idx - 1) != ' ')
            			# short gap (between letters) — three units long

            			# It's 3 units long but here we sleep for only 2 units because the
            			# first unit was already executed as an inter-element gap immediately
            			# after the previous 'di' or 'dah'
            			#p "inter-letter"
            			@light_controller.light(@light_key)
            			morse_pause 2
          			end

        		end

        		morse_msg_array_idx = morse_msg_array_idx + 1

      		end

      		# It's 7 units long before we restart the message but here we sleep for only 6 units because the first unit was already executed as an inter-element gap immediately after the previous 'di' or 'dah'
      		#p "inter-word"
      		@light_controller.off
      		morse_pause 6

  	end
  	
  end

  def morse_pause(unit)
    sleep_duration = MORSE_CODE_UNIT_LENGTH * unit
    sleep(sleep_duration)
  end
end