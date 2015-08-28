ActiveAdmin.register EmailApprove do
  permit_params :author_id , :first_name , :last_name , :outlet , :email



  index do
    id_column
    column :author_id
    column :first_name
    column :last_name
    column :outlet
    column :email
    actions
  end

end
