require 'test_helper'

class AtomicJsonTest < Minitest::Test

  def setup
    @order = create(:order)
  end

  def teardown
    @order = nil
  end

  def test_update_jsonb_top_level_string_field
    @order.jsonb_update!(:data, string_field: 'Hello')
    assert_equal 'Hello', @order.reload.data['string_field']
  end

  def test_update_jsonb_top_level_int_field
    @order.jsonb_update!(:data, int_field: 4)
    assert_equal 4, @order.reload.data['int_field']
  end

  def test_update_jsonb_top_level_array_field
    @order.jsonb_update!(:data, array_field: [10, 12, 'asa'])
    assert_equal [10, 12, 'asa'], @order.reload.data['array_field']
  end

  def test_update_jsonb_top_level_boolean_field
    @order.jsonb_update!(:data, boolean_field: false)
    assert_equal false, @order.reload.data['boolean_field']
  end

  def test_update_jsonb_non_exisiting_field_raise_error
    assert_raises(AtomicJson::Updater::InvalidColumnError) do
      @order.jsonb_update!(:no_data, int_field: 4)
    end
  end

end
