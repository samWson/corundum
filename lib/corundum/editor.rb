require 'io/console'

module Corundum
  class Editor
    ASCII_CONTROL_CODES = 0..31
    ASCII_CONTROL_KEY = 0x1f
    TOP_LEFT = [0, 0]
    ROW_INDEX = 0

    def initialize
      @append_buffer = AppendBuffer.new
    end

    def main
      STDIN.raw do |io|
        program_running = true

        while program_running
          refresh_screen
          program_running = process_keypress(io)
        end
      end

      STDIN.cooked!

      STDOUT.clear_screen
      exit(0)
    end

    private

    def refresh_screen
      STDOUT.clear_screen
      draw_rows
      STDOUT.cursor = TOP_LEFT
      STDOUT.write(@append_buffer.contents)
      STDOUT.cursor = TOP_LEFT
    end

    def process_keypress(io)
      ch = read_key(io)

      # Uncomment to help debug
      # print_keypress(ch)

      case ch
      when control_key('q')
        return nil
      end

      ch
    end

    def read_key(io)
      io.getch.ord
    end

    def draw_rows
      screen_rows = STDIN.winsize[ROW_INDEX]

      (0...screen_rows).each do |row|
        if row == 0
          @append_buffer << "\r\n"
          next
        end

        @append_buffer << '~'
        @append_buffer << "\r\n" if row < screen_rows - 1
      end
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

  class AppendBuffer
    def initialize
      @characters = []
    end

    def <<(string)
      @characters.concat(string.chars)
    end

    def contents
      @characters.join
    end
  end
end
