class AddEmailSubjectToPitches < ActiveRecord::Migration
  def change
    add_column :pitches, :email_subject, :string, limit: 2500
  end
end
