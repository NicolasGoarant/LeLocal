module ApplicationHelper
# Always return a readable category name (works with String or Category)
def category_display(cat)
  return "" if cat.blank?
  cat.respond_to?(:name) ? cat.name.to_s : cat.to_s
end

end
