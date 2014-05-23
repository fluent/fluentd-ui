class CreateFluentds < ActiveRecord::Migration
  def change
    create_table :fluentds do |t|
      t.string :variant, null: false # fluentd, td-agent, or remote
      t.string :pid_file
      t.string :log_file
      t.string :config_file

      t.timestamps
    end
  end
end
