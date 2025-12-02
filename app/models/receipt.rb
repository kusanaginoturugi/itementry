class Receipt < ApplicationRecord
  has_many :receipt_details, dependent: :destroy

  accepts_nested_attributes_for :receipt_details, allow_destroy: true

  require 'set'

  before_validation :assign_default_name, on: :create
  before_validation :calculate_totals
  before_save :calculate_totals

  validates :name, presence: true, format: { with: /\A\d+\z/, message: "は数字のみで入力してください" }
  validates :total_count, :total_value, presence: true
  validate :validate_unique_item_codes

  private

  def calculate_totals
    valid_details = receipt_details.reject(&:marked_for_destruction?)
    self.total_count = valid_details.sum { |detail| detail.count.to_i }
    self.total_value = valid_details.sum { |detail| detail.sum_value.to_i }
  end

  def assign_default_name
    return if name.present?

    self.name = self.class.next_name
  end

  def validate_unique_item_codes
    seen = Set.new
    duplicates = Set.new

    receipt_details.reject(&:marked_for_destruction?).each do |detail|
      code = detail.item_code.to_s.strip
      next if code.blank?

      duplicates.add(code) if seen.include?(code)
      seen.add(code)
    end

    return if duplicates.empty?

    errors.add(:base, "同じ商品コードを1つのレシートに複数登録できません（#{duplicates.to_a.join(', ')}）")
  end

  class << self
    def next_name
      last_numeric = order(created_at: :desc).detect { |receipt| receipt.name.to_s.match?(/\A\d+\z/) }
      last_value = last_numeric&.name.to_i
      (last_value + 1).to_s
    end
  end
end
