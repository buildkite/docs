# frozen_string_literal: true

class Emoji::Parser
  SHORTCODE_REGEXP = /
    # Like a short code, but with slash-escaped colons
    # (matches with higher priority)
    \\ : [\w+-]+ \\ :

    |

    # Colon-sandwiched word
    : [\w+-]+ :

    # Optional skin tone modifier
    (?: :skin-tone-[2-6]: )?
  /x

  def self.parse(catalogues, text, **options, &block)
    new(catalogues, **options).parse(text, &block)
  end

  def initialize(catalogues, sanitize: true, mutate: false)
    @catalogues = catalogues
    @sanitize = sanitize
    @mutate = mutate
  end

  def parse(text)
    return text if text.blank?

    # We use gsub! to replace emojis in strings, which avoids creating new
    # strings in memory for every gsub we do. So if we're not mutatings the
    # original string, we can cheat, create a dup of it here, and mutate that
    # instead.
    text = text.dup if not @mutate

    text = EscapeUtils.escape_html(text) if @sanitize

    text.gsub!(SHORTCODE_REGEXP) do |match|
      # Escaped shortcodes "\\:code\\:" => ":code:"
      if match[0] == "\\"
        ":#{match[2...-2]}:"
      elsif emoji = find(match)
        yield(match, emoji)
      else
        match
      end
    end

    text
  end

  private

  def find(match)
    @catalogues.each do |catalogue|
      emoji = catalogue.find(match)
      if emoji
        return emoji
      end
    end
    return nil
  end
end
