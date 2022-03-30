require 'test_helper'

module Corundum
  class AppendBufferTest < Minitest::Test
    def setup
      @buffer = Corundum::AppendBuffer.new
    end

    def test_appending_and_contents
      @buffer << 'hello'
      assert_equal 'hello', @buffer.contents
    end
  end
end
