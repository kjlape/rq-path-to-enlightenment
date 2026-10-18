class AddAdminToUsers < ActiveRecord::Migration[7.1]
  def up
    add_column :users, :admin, :boolean, default: false, null: false

    # Existing users become admins so current content stays manageable (bug 001).
    execute "UPDATE users SET admin = true"
  end

  def down
    remove_column :users, :admin
  end
end
