module PillHelper

  def pill(label, style, size = "medium")
    "<span class=\"pill pill--#{style} pill--#{size}\">#{label}</span>"
  end
end
