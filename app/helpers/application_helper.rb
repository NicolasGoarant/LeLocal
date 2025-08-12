module ApplicationHelper
# Always return a readable category name (works with String or Category)
def category_display(cat)
  return "" if cat.blank?
  cat.respond_to?(:name) ? cat.name.to_s : cat.to_s
  # Affiche le libellé humain d\047une catégorie Space
  def category_display(val)
    pair = Space::CATEGORIES.find { |label, key| key.to_s == val.to_s }
    pair ? pair.first : (val.to_s.strip.empty? ? "Autre" : val.to_s.humanize)
  end
end

end
