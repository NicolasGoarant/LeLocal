module SpacesHelper
    def get_category_color(category)
      case category
      when "event_space" then "#4CAF50"
      when "meeting_room" then "#2196F3"
      when "creative_studio" then "#FF9800"
      when "coworking" then "#9C27B0"
      when "training_room" then "#F44336"
      else "#607D8B"
      end
    end
    
    def get_category_icon(category)
      icon = case category
      when "event_space" then "fa-calendar-check"
      when "meeting_room" then "fa-handshake"
      when "creative_studio" then "fa-paint-brush"
      when "coworking" then "fa-laptop"
      when "training_room" then "fa-chalkboard-teacher"
      else "fa-building"
      end
      
      "<i class='fas #{icon}'></i>".html_safe
    end
  end