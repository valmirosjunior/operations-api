class CreateOperations < ActiveRecord::Migration[8.0]
  def change
    create_table :operations do |t|
      t.string :external_id
      t.decimal :amount
      t.string :currency

      t.timestamps
    end

    add_index :operations, :external_id, unique: true
  end
end
