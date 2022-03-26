require 'io/console'

module Corundum
  class Editor
    ASCII_CONTROL_CODES = 0..31
    ASCII_CONTROL_KEY = 0x1f

    def main
      STDIN.raw!

      while true
        ch = nil
        ch = STDIN.getch().ord

        if ASCII_CONTROL_CODES.include?(ch)
          printf("%d\r\n", ch)
        else
          printf("%d ('%c')\r\n", ch, ch)
        end

        break if ch == control_key('q')
      end

      STDIN.cooked!

      exit(0)
    end

    private

    def control_key(key)
      key.ord & ASCII_CONTROL_KEY
    end
  end
end
