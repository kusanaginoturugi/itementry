ITEM_TYPE_LABELS = YAML.load_file(Rails.root.join("config/item_types.yml")).transform_keys(&:to_i).freeze
