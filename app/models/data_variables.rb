class DataVariables
  DIR_PATH = [Rails.root, "/data"].join.freeze

  def self.entries(files = Dir.entries(DIR_PATH))
    files
      .select { |s| s.match?(/.ya?ml$/) }
      .reject { |s| s.match?("schema")  }
  end

  def self.set
    entries.each do |s|
      DataFile.new(s).set_env_variable
    end
  end

  class DataFile
    attr_reader :file_name

    def initialize(file_name)
      @file_name = file_name
    end

    def variable_name_string
      @variable_name_string ||= file_name
        .gsub(/\.ya?ml$/, '')
        .gsub(/-/, '_')
        .upcase
        .to_sym
    end

    def set_env_variable
      if Object.const_source_location(variable_name_string).nil?
        Object.const_set(
          variable_name_string,
          YAML.load_file("#{DIR_PATH}/#{file_name}").freeze,
        )
      end
    end
  end
end
