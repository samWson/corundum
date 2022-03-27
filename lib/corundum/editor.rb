require 'io/console'

module Corundum
  class Editor
    ASCII_CONTROL_CODES = 0..31
    ASCII_CONTROL_KEY = 0x1f

    def main
      STDIN.raw do |io|
        while true
          process_keypress(io)
        end
      end

      STDIN.cooked!
    end

    private

    def process_keypress(io)
      ch = read_key(io)

      # Uncomment to help debug
      # print_keypress(ch)

      case ch
      when control_key('q')
        exit(0)
      end
    end

    def read_key(io)
      io.getch.ord
    end

    def print_keypress(ch)
      if ASCII_CONTROL_CODES.include?(ch)
        printf("%d\r\n", ch)
      else
        printf("%d ('%c')\r\n", ch, ch)
      end
    end

    def control_key(key)
      key.ord & ASCII_CONTROL_KEY
    end
  end
end
