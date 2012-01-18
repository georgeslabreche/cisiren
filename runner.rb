require_relative 'morse_encoder'
require_relative 'light_thread'

class Runner
  p $:

  # The message we want the red light to send out when the build fails
  BUILD_FAIL_MORSE_MESSAGE = "SOS"

  morse_encoder = MorseEncoder.new()
  morse_msg = morse_encoder.encode(BUILD_FAIL_MORSE_MESSAGE);

  p morse_msg

  red_light_thread = Thread.new { LightThread.new(morse_msg, "RED").run}
  red_light_thread.join


end