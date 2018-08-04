require 'test_helper'
require 'minitest/benchmark'

class AtomicJsonBenchmark < Minitest::Benchmark

  def setup
    @order = create(:order)
  end

  def teardown
    @order = nil
  end

  def bench_update_columns
    assert_performance_linear 0 do
      data = @order.data
      data['string_field'] = 'Hello'
      @order.update_columns(data: data)
    end
  end

  def bench_update
    assert_performance_linear 0 do
      data = @order.data
      data['string_field'] = 'Hello'
      @order.update(data: data)
    end
  end

  def bench_jsonb_update_columns
    assert_performance_linear 0 do
      @order.jsonb_update_columns(:data, string_field: 'Hello')
    end
  end

end
