require 'test_helper'

class UpdaterTest < Minitest::Test

  def setup
    @order = create(:order)
  end

  def teardown
    @order = nil
  end

  def test_update_json_top_level_string_field
    @order.json_update_columns(jsonb_data: {
      string_field: 'Hello'
    })
    assert_equal 'Hello', @order.reload.jsonb_data['string_field']
  end

  def test_can_update_json_column
    @order.json_update_columns(json_data: {
      string_field: 'Hello'
    })
    assert_equal 'Hello', @order.reload.json_data['string_field']
  end

  def test_update_json_top_level_int_field
    @order.json_update_columns(jsonb_data: {
      int_field: 4
    })
    assert_equal 4, @order.reload.jsonb_data['int_field']
  end

  def test_update_json_top_level_date_field
    @order.json_update_columns(jsonb_data: {
      timestamp: Date.parse('2018/08/12')
    })
    assert_equal '2018-08-12', @order.reload.jsonb_data['timestamp']
  end

  def test_update_json_top_level_time_field
    @order.json_update_columns(jsonb_data: {
      timestamp: Time.parse('2018/08/12 10:00 UTC')
    })
    assert_equal '2018-08-12T10:00:00.000Z', @order.reload.jsonb_data['timestamp']
  end

  def test_update_json_top_level_nil_field
    @order.json_update_columns(jsonb_data: {
      null_field: nil
    })
    assert_nil @order.reload.jsonb_data['null_field']
  end

  def test_update_json_top_level_array_field
    @order.json_update_columns(jsonb_data: {
      array_field: [10, 12, 'asa']
    })
    assert_equal [10, 12, 'asa'], @order.reload.jsonb_data['array_field']
  end

  def test_update_json_top_level_boolean_field
    @order.json_update_columns(jsonb_data: {
      boolean_field: false
    })
    assert_equal false, @order.reload.jsonb_data['boolean_field']
  end

  def test_update_json_multiple_top_level_keys
    @order.json_update_columns(jsonb_data: {
      timestamp: Time.parse('2018/08/12 10:00 UTC'),
      null_field: nil
    })
    assert_equal '2018-08-12T10:00:00.000Z', @order.reload.jsonb_data['timestamp']
    assert_nil @order.reload.jsonb_data['null_field']
  end

  def test_update_json_nested_field
    @order.json_update_columns(jsonb_data: {
      nested_field: {
        nested_one: {
          nested_two: 'salut!',
          nested_three: 'hola!',
        }
      }
    })
    assert_equal(
      {
        nested_one: {
          nested_two: 'salut!',
          nested_three: 'hola!',
          nested_four: 'yo',
          nested_five: nil
        }
      }.as_json,
      @order.reload.jsonb_data['nested_field']
    )
  end

  def test_callback_are_invoked_when_using_json_update
    assert !@order.before_update_ran
    @order.json_update(jsonb_data: { string_field: 'Hello' })
    assert @order.before_update_ran
  end

  def test_callback_are_not_invoked_when_using_json_update_columns
    @order.json_update_columns(jsonb_data: { string_field: 'Hello' })
    assert !@order.before_update_ran
  end

  def test_record_is_touched_using_json_update
    assert_nil @order.updated_at
    @order.json_update(jsonb_data: { string_field: 'Hello' })
    assert @order.reload.updated_at.present?
  end

  def test_validations_are_not_ran_using_json_update_columns
    @order.json_update_columns(jsonb_data: { string_field: nil })
    assert @order.reload.errors.empty?
  end

  def test_validations_are_ran_using_json_update
    @order.json_update(jsonb_data: { string_field: nil })
    assert @order.reload.invalid?
    assert 'JSON string is missing', @order.errors[:jsonb_data].join
  end

  def test_validations_raise_exception_using_json_update!
    assert_raises ActiveRecord::RecordInvalid do
      @order.json_update!(jsonb_data: { string_field: nil })
    end
  end

end
