class AddPositionToMinitestTestMethods < ActiveRecord::Migration[7.1]
  def up
    add_column :minitest_test_methods, :position, :integer

    # Backfill positions from the existing created_at order within each class.
    MinitestTestClass.find_each do |minitest_test_class|
      minitest_test_class.minitest_test_methods.order(:created_at).each_with_index do |method, index|
        method.update_column(:position, index) # rubocop:disable Rails/SkipsModelValidations
      end
    end

    change_column_null :minitest_test_methods, :position, false
  end

  def down
    remove_column :minitest_test_methods, :position
  end
end
