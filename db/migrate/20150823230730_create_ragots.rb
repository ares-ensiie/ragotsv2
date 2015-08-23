class CreateRagots < ActiveRecord::Migration
  def change
    create_table :ragots do |t|
      t.string :message
      t.string :uid

      t.timestamps null: false
    end
  end
end
