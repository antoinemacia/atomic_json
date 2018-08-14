class CreateMockTestTable < ActiveRecord::Migration[5.1]

  def change
    create_table :orders do |t|
      t.jsonb :jsonb_data
      t.json :json_data
      t.timestamps
    end
  end

end
