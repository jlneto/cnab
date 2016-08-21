module Cnab
  class Configs400
    def initialize(version)
      raise Exceptions::VersionNotImplemented unless File.directory?("#{Cnab.config_path}/#{version}")

      @header_arquivo = Config400.new(version, 'header_arquivo')
      @detalhe = Config400.new(version, 'detalhe_arquivo')
      @detalhe_complemento = Config400.new(version, 'detalhe_complemento_arquivo')
      @trailer_arquivo = Config400.new(version, 'trailer_arquivo')
    end

    def method_missing(method_name)
      return instance_variable_get("@#{method_name}") if instance_variable_defined?("@#{method_name}")
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      return true if instance_variable_defined?("@#{method_name}")
      super
    end
  end
end