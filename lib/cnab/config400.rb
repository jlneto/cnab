module Cnab
class Config400
    def initialize(version, file)
      @definition = YAML.load_file("#{Cnab.config_path}/#{version}/#{file}.yml")
    end

    def fields
      @definition
    end

    def method_missing(method_name)
      range = @definition[method_name.to_s].split('|')
      p1 = range[1].strip.to_i - 1
      p2 = range[2].strip.to_i - 1
      p1..p2
    end

    def respond_to_missing?(method_name, include_private = false)
      return true unless @definition[method_name.to_s].nil?
      super
    end
  end
end