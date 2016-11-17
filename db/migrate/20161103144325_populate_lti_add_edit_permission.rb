class PopulateLtiAddEditPermission < ActiveRecord::Migration[4.2]
  tag :postdeploy

  def change
    DataFixup::AddRoleOverridesForNewPermission.run(:manage_content, :lti_add_edit)
  end
end
