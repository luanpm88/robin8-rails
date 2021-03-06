class AddColumnProfileToKols < ActiveRecord::Migration
  def change
    add_column :kols, :job_info, :string
    change_column :kols, :desc, :text
    add_column :kols, :avatar_url, :string
    add_column :kols, :kol_role, :string, :limit => 80, :default => 'public'
    add_column :kols, :role_apply_status, :string, :default => 'pending'
    add_column :kols, :role_apply_time, :datetime
    add_column :kols, :role_check_time, :datetime
    add_column :kols, :role_check_remark, :string

    add_column :kols, :longitude, :float
    add_column :kols, :latitude, :float

    add_column :kols, :is_hot, :boolean, :default => false


    add_index :kols, :is_hot
    add_index :kols, :kol_role
  end
end
