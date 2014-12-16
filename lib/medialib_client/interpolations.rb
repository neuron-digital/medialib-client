Paperclip.interpolates :parent_type do |attachment, style|
  attachment.instance.attachable_type.to_s.pluralize.downcase
end

Paperclip.interpolates :date_to_path do |attachment, style|
  attachment.instance.created_at.strftime("/%Y/%m")
end

Paperclip.interpolates :parent_id do |attachment, style|
  attachment.instance.attachable_id
end

Paperclip.interpolates :gallery_id do |attachment, style|
  attachment.instance.gallery_id
end

Paperclip.interpolates :custom_style do |attachment, style|
  style == :original ? "" : "_#{style}"
end

Paperclip.interpolates :gallery_date do |attachment, style|
  attachment.instance.gallery.created_at.strftime("/%Y/%m")
end
