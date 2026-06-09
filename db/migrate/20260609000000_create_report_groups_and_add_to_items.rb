require "csv"
require "set"

class CreateReportGroupsAndAddToItems < ActiveRecord::Migration[8.1]
  def up
    create_table :report_groups do |t|
      t.string :name, null: false
      t.string :code

      t.timestamps
    end

    add_reference :items, :report_group, foreign_key: true

    report_groups_path = Rails.root.join("db/report_groups.csv")
    report_group_ids_path = Rails.root.join("db/report_group_id.csv")

    CSV.foreach(report_groups_path, headers: true) do |row|
      execute <<~SQL.squish
        INSERT INTO report_groups (id, name, code, created_at, updated_at)
        VALUES (
          #{connection.quote(row["id"].to_i)},
          #{connection.quote(row["name"].to_s.strip)},
          #{connection.quote(row["code"].to_s.strip.presence)},
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP
        )
      SQL
    end

    assigned_codes = Set.new
    CSV.foreach(report_group_ids_path, headers: true) do |row|
      code = row["code"].to_s.strip
      next if code.blank? || assigned_codes.include?(code)

      assigned_codes << code
      execute <<~SQL.squish
        UPDATE items
        SET report_group_id = #{connection.quote(row["report_group_id"].to_i)}
        WHERE item_code = #{connection.quote(code)}
      SQL
    end
  end

  def down
    remove_reference :items, :report_group, foreign_key: true
    drop_table :report_groups
  end
end
