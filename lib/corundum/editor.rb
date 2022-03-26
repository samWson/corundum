require 'io/console'

module Corundum
  class Editor
    def main
      ch = nil
      while ch != 'q'
        ch = STDIN.getch()
        puts ch
      end

      exit(0)
    end
  end
end
