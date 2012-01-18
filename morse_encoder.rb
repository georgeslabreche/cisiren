# http://en.wikipedia.org/wiki/Morse_code
class MorseEncoder
  INTERNATIONAL_MORSE_CODE_MAP = {
    ' ' => '  ',
    'A' => '.-',
    'B' => '-...',
    'C' => '-.-.',
    'D' => '-..',
    'E' => '.',
    'F' => '..-.',
    'G' => '--.',
    'H' => '....',
    'I' => '..',
    'J' => '.---',
    'K' => '-.-',
    'L' => '.-..',
    'M' => '--',
    'N' => '-.',
    'O' => '---',
    'P' => '.--.',
    'Q' => '--.-',
    'R' => '.-.',
    'S' => '...',
    'T' => '-',
    'U' => '..-',
    'V' => '...-',
    'W' => '.--',
    'X' => '-..-',
    'Y' => '-.--',
    'Z' => '--..',
    '1' => '.----',
    '2' => '..---',
    '3' => '...--',
    '4' => '....-',
    '5' => '.....',
    '6' => '-....',
    '7' => '--...',
    '8' => '---..',
    '9' => '----.',
    '0' => '-----'
  }

  def encode(message)
    # The variable that will contain the message in morse code
    morse_code_msg = '';

    # Build array of message characters
    msg_char_array = message.chars.to_a

    # Encode each character of the message to its morse code equivalent
    msg_char_array.each{ |message_char|
      morse_code_elem = INTERNATIONAL_MORSE_CODE_MAP[message_char]

      # Characters that are not covered by morse code are simply not processed, we skip to the next character
      if morse_code_elem != nil

        # If it is end of a word, word space will have been added.
        # In our morse encoded message, a space between words is two whitespaces: '  '
        #
        # But prior to adding this word space, the previous loop added a trailing letter space.
        # In our morse encoded message, a space between letters is one whitespaces: '  '
        # We remove that trailing letter space.
        if morse_code_elem == '  '
          morse_code_msg = morse_code_msg.rstrip
        end

        # build the morse encoded message
        morse_code_msg += morse_code_elem

        # In the morse code message we are building, we want to put whitespace between our morse code elements
        if morse_code_elem != '  '
          morse_code_msg += ' '
        end
      end



    }

    # Return message in morse code
    return morse_code_msg.rstrip
  end

end