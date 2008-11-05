class CreateIntTags < ActiveRecord::Migration
  def self.up
    create_table :int_tags do |t|
      t.string :tagname
      t.integer :value

      t.timestamps
    end
  end

  def self.down
    drop_table :int_tags
  end
end
