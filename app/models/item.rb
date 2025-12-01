class Item < ApplicationRecord
  validates :name, :value, :item_code, presence: true
  validates :item_code, uniqueness: true, format: { with: /\A\d+\z/, message: "は数字のみで入力してください" }
end
