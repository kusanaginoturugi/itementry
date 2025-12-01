items = (1..100).map do |index|
  {
    item_code: format("%04d", index),
    name: "Sample Item #{format('%03d', index)}",
    value: (index * 100) + 500
  }
end

items.each do |attrs|
  item = Item.find_or_initialize_by(name: attrs[:name])
  item.item_code = attrs[:item_code]
  item.value = attrs[:value]
  item.save!
end
