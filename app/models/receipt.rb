class Receipt < ApplicationRecord
  belongs_to :book
  has_many :receipt_details, dependent: :destroy

  accepts_nested_attributes_for :receipt_details, allow_destroy: true

  before_validation :assign_default_name, on: :create
  before_validation :assign_default_book
  before_validation :discard_blank_or_zero_details
  before_validation :calculate_totals
  before_save :calculate_totals

  validates :name, presence: true, format: { with: /\A\d+\z/, message: "は数字のみで入力してください" }
  validates :total_count, :total_value, presence: true

  private

  def calculate_totals
    valid_details = receipt_details.reject(&:marked_for_destruction?)
    self.total_count = valid_details.sum { |detail| detail.count.to_i }
    self.total_value = valid_details.sum { |detail| detail.sum_value.to_i }
  end

  def assign_default_book
    self.book ||= Book.default
  end

  def assign_default_name
    return if name.present?

    self.name = self.class.next_name
  end

  def discard_blank_or_zero_details
    receipt_details.each do |detail|
      next if detail.marked_for_destruction?

      code = detail.item_code.to_s.strip
      count = detail.count.to_i
      detail.mark_for_destruction if code.blank? || count.zero?
    end
  end

  class << self
    def next_name
      last_numeric = order(created_at: :desc).detect { |receipt| receipt.name.to_s.match?(/\A\d+\z/) }
      last_value = last_numeric&.name.to_i
      (last_value + 1).to_s
    end
  end
end
