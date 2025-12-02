module ApplicationHelper
  def item_code_tone(code)
    first = code.to_s[0]&.upcase
    case first
    when '0' then '#f8fafc'   # light gray-blue
    when '1' then '#eef2ff'   # pastel indigo
    when '2' then '#ecfdf3'   # pastel green
    when '3' then '#fff1f2'   # pastel rose
    when '4' then '#f3e8ff'   # pastel purple
    when '5' then '#fff7ed'   # pastel orange
    when '6' then '#e0f2fe'   # pastel sky
    when '7' then '#e7fff4'   # pastel mint
    when '8' then '#fefce8'   # pastel sand
    when '9' then '#f5f3ff'   # pastel lavender
    else '#f8fafc'
    end
  end

  def item_code_style(code)
    "background-color: #{item_code_tone(code)} !important;"
  end
end
