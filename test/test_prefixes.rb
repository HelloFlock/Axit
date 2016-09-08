require 'minitest/autorun'
require 'axit'
require 'pry'

class AxitTest < Minitest::Test
  def test_controller_prefix_string_constant
    Axit::Controllers::PREFIX == 'Auth::Controllers'
  end

  def test_view_prefix_string_constant
    Axit::Views::PREFIX == 'Auth::Views'
  end
end
