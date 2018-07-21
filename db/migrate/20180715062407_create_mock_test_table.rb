class CreateMockTestTable < ActiveRecord::Migration[5.1]

  def change
    create_table :orders do |t|
      t.jsonb :data
    end
  end

end
