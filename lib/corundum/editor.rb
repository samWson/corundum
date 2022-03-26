require 'io/console'

module Corundum
  class Editor
    ASCII_CONTROL_CODES = 0..31

    def main
      STDIN.raw!

      ch = nil
      while ch != 'q'.ord
        ch = STDIN.getch().ord

        if ASCII_CONTROL_CODES.include?(ch)
          printf("%d\n", ch)
        else
          printf("%d ('%c')\n", ch, ch)
        end
      end

      STDIN.cooked!

      exit(0)
    end
  end
end
