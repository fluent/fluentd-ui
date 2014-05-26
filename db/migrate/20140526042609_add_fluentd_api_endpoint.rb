class AddFluentdApiEndpoint < ActiveRecord::Migration
  def change
    add_column :fluentds, :api_endpoint, :string, default: "http://localhost:24220/"
  end
end
