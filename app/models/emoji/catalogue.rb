# frozen_string_literal: true

class Emoji::Catalogue
  Item = Struct.new(:name, :unicode, :aliases, :image, :catalogue) do
    def url
      File.join(catalogue.host, image)
    end
  end

  def self.load(name, host, filename)
    new(name, host, JSON.parse(File.read(filename)))
  end

  attr_reader :name, :host, :emojis

  def initialize(name, host, emojis)
    @name = name
    @host = host
    @index = {}
    @emojis = []

    emojis.each do |emoji|
      @emojis << item = Item.new(emoji["name"],
                                 convert_to_unicode(emoji["unicode"]),
                                 emoji["aliases"],
                                 emoji["image"],
                                 self)

      @index[":#{item.name}:"] = item

      item.aliases.each do |alias_name|
        @index[":#{alias_name}:"] = item
      end

      modifiers = emoji["modifiers"].freeze
      if modifiers.present?
        modifiers.each do |modifier|
          modified = Item.new(item.name, convert_to_unicode(modifier["unicode"]), [], modifier["image"], self)

          @emojis << modified

          @index[":#{item.name}::#{modifier["name"]}:"] = modified

          emoji["aliases"].each do |alias_name|
            @index[":#{alias_name}::#{modifier["name"]}:"] = modified
          end
        end
      end
    end

    @index.freeze
    @emojis.freeze
  end

  def find(emoji)
    @index[emoji]
  end

  def inspect
    "#<Emoji::Catalogue name: #{@name.inspect}, host: #{@host.inspect}, emojis: [...], index: {...}>"
  end

  private

  def convert_to_unicode(code)
    return nil if code.blank?
    code.split("-").map(&:hex).pack("U*")
  end
end
