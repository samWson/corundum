require 'io/console'

module Corundum
  class Editor
    def main
      STDIN.raw!

      ch = nil
      while ch != 'q'
        ch = STDIN.getch()
        puts ch
      end

      STDIN.cooked!

      exit(0)
    end
  end
end
