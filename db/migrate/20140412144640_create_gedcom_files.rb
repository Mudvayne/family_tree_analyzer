class CreateGedcomFiles < ActiveRecord::Migration
  def change
    create_table :gedcom_files do |t|
      t.references :user, index: true
      t.binary :data
      t.string :filename

      t.timestamps
    end
  end
end
