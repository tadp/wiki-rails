class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :title
      t.text :content
      t.boolean :display, default: false
      t.integer :document_id
      t.timestamps
    end
  end
end
