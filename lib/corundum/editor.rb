require 'io/console'

module Corundum
  class Editor
    ASCII_CONTROL_CODES = 0..31
    ASCII_CONTROL_KEY = 0x1f
    ASCII_ESCAPE_CODE = 27
    TOP_LEFT = [0, 0]
    ROW_INDEX = 0
    COLUMN_INDEX = 1

    LEFT_ORDINAL = 1000
    RIGHT_ORDINAL = 1001
    UP_ORDINAL = 1002
    DOWN_ORDINAL = 1003
    PAGE_UP_ORDINAL = 1004
    PAGE_DOWN_ORDINAL = 1005
    HOME_ORDINAL = 1006
    END_ORDINAL = 1007

    EDITOR_KEY = {
      arrow_left: LEFT_ORDINAL,
      arrow_right: RIGHT_ORDINAL,
      arrow_up: UP_ORDINAL,
      arrow_down: DOWN_ORDINAL,
      page_up: PAGE_UP_ORDINAL,
      page_down: PAGE_DOWN_ORDINAL,
      home: HOME_ORDINAL,
      end: END_ORDINAL
    }.freeze

    def initialize
      @append_buffer = AppendBuffer.new
      @cursor_x = 0
      @cursor_y = 0
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
      STDOUT.write(@append_buffer.contents)
      STDOUT.cursor = [@cursor_y, @cursor_x]
    end

    def process_keypress(io)
      ch = read_key(io)

      # Uncomment to help debug
      # print_keypress(ch)

      case ch
      when control_key('q')
        return nil

      when HOME_ORDINAL
        @cursor_x = 0
        STDOUT.cursor = [@cursor_x, @cursor_y]

      when END_ORDINAL
        @cursor_x = STDIN.winsize[COLUMN_INDEX]
        STDOUT.cursor = [@cursor_x, @cursor_y]

      when LEFT_ORDINAL, RIGHT_ORDINAL, UP_ORDINAL, DOWN_ORDINAL
        move_cursor(ch)

      when PAGE_UP_ORDINAL, PAGE_DOWN_ORDINAL
        move_page(ch)
      end

      ch
    end

    def read_key(io)
      ordinal = io.getch.ord

      if ordinal == ASCII_ESCAPE_CODE
        sequence = (0..1).each_with_object([]) do |index, bytes|
          bytes[index] = io.getch.ord
        end

        return ASCII_ESCAPE_CODE unless sequence[0]
        return ASCII_ESCAPE_CODE unless sequence[1]

        if sequence[0] == '['.ord
          if (0..9).include?(sequence[1])
            bytes[2] = io.getch.ord
            return ASCII_ESCAPE_CODE unless sequence[2]

            if sequence[1] == key('~')
              case sequence[1]
              when key('1')
                return EDITOR_KEY[:home]
              when key('4')
                return EDITOR_KEY[:end]
              when key('5')
                return EDITOR_KEY[:page_up]
              when key('6')
                return EDITOR_KEY[:page_down]
              when key('7')
                return EDITOR_KEY[:home]
              when key('8')
                return EDITOR_KEY[:end]
              end
            end
          else
            case sequence[1]
            when 'A'.ord
              return EDITOR_KEY[:arrow_up]
            when 'B'.ord
              return EDITOR_KEY[:arrow_down]
            when 'C'.ord
              return EDITOR_KEY[:arrow_right]
            when 'D'.ord
              return EDITOR_KEY[:arrow_left]
            when 'H'.ord
              return EDITOR_KEY[:home]
            when 'F'.ord
              return EDITOR_KEY[:end]
            end
          end
        elsif sequence[0] == 'O'.ord
          case sequence[1]
          when 'H'.ord
            return EDITOR_KEY[:home]
          when 'F'.ord
            return EDITOR_KEY[:end]
          end
        end

        return ASCII_ESCAPE_CODE
      else
        ordinal
      end
    end

    def draw_rows
      screen_rows = STDIN.winsize[ROW_INDEX]
      screen_columns = STDIN.winsize[COLUMN_INDEX]

      (0...screen_rows).each do |row|
        if row == 0
          @append_buffer << "\r\n"
          next
        end

        if row == screen_rows / 3
          welcome = "Corundum -- version #{Corundum::VERSION}"
          welcome = welcome.slice(0, screen_columns) if welcome.length > screen_columns

          padding = (screen_columns - welcome.length) / 2
          if padding > 0
            welcome = welcome.rjust(padding)
            welcome = welcome.prepend('~')
          end

          @append_buffer << welcome
        else
          @append_buffer << '~'
        end

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

    def move_cursor(ordinal)
      case ordinal
      when key(EDITOR_KEY[:arrow_left])
        if @cursor_x != 0
          @cursor_x -= 1
          STDOUT.cursor_left(1)
        end
      when key(EDITOR_KEY[:arrow_right])
        if @cursor_x != STDIN.winsize[COLUMN_INDEX] - 1
          @cursor_x += 1
          STDOUT.cursor_right(1)
        end
      when key(EDITOR_KEY[:arrow_up])
        if @cursor_y != 0
          @cursor_y -= 1
          STDOUT.cursor_up(1)
        end
      when key(EDITOR_KEY[:arrow_down])
        if @cursor_y != STDIN.winsize[ROW_INDEX] - 1
          @cursor_y += 1
          STDOUT.cursor_down(1)
        end
      end
    end

    def move_page(ordinal)
      screen_rows = STDIN.winsize[ROW_INDEX]

      if ordinal == PAGE_UP_ORDINAL
        (screen_rows - 1).times { |n| move_cursor(EDITOR_KEY[:arrow_up])}
      else
        (screen_rows - 1).times { |n| move_cursor(EDITOR_KEY[:arrow_down])}
      end
    end

    def key(key)
      key.ord
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
