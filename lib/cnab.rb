require "cnab/version"
require "yaml"

module Cnab
  autoload :Line, 'cnab/line'
  autoload :MergedLines, 'cnab/merged_lines'
  autoload :Detalhe, 'cnab/detalhe'
  autoload :Retorno, 'cnab/retorno'
  autoload :Config, 'cnab/config'
  autoload :Configs, 'cnab/configs'
  autoload :Config400, 'cnab/config400'
  autoload :Configs400, 'cnab/configs400'
  autoload :Detalhe400, 'cnab/detalhe400'
  autoload :PrettyInspect, 'cnab/pretty_inspect'

  autoload :Exceptions, 'cnab/exceptions'

  def self.parse(file = nil, merge = false, version = 'itau_400')
    raise Exceptions::NoFileGiven if file.nil?

    file_type = detect_cnab_type(file)
    if file_type == 240
      parse_240(file, version, merge)
    else
      parse_400(file, version, merge )
    end
  end

  def self.detect_cnab_type(file)
    file_type = nil
    File.open(file, 'rb') do |f|
      first_line = f.gets
      if first_line.size == 240
        file_type = 240
      else
        file_type = 400
      end
    end
    file_type
  end

  def self.parse_240(file, version, merge = false)
    validate_missing_lines file, 5
    definition = Cnab::Configs.new(version)
    File.open(file, 'rb') do |f|
      header_arquivo = Line.new(f.gets, definition.header_arquivo)
      header_lote = Line.new(f.gets, definition.header_lote)

      detalhes = []
      while(line = f.gets)
        if line[7] == "5"
          trailer_lote = Line.new(line, definition.trailer_lote)
          break
        end
        if merge
          detalhes << Detalhe.merge(line, f.gets, definition)
        else
          detalhes << Detalhe.parse(line, definition)
        end
      end

      trailer_arquivo = Line.new(f.gets, definition.trailer_arquivo)
      Retorno.new({ :header_arquivo => header_arquivo,
                    :header_lote => header_lote,
                    :detalhes => detalhes,
                    :trailer_lote => trailer_lote,
                    :trailer_arquivo => trailer_arquivo  })
    end
  end

  def self.parse_400(file, version, merge = false)
    validate_missing_lines file, 3
    definition = Cnab::Configs400.new(version)

    File.open(file, 'rb') do |f|
      header_arquivo = Line.new(f.gets, definition.header_arquivo)

      detalhes = []
      while(line = f.gets)
        if line[0] == '9'
          trailer_arquivo = Line.new(line, definition.trailer_arquivo)
          break
        end
        if merge
          detalhes << Detalhe400.merge(line, f.gets, definition)
        else
          detalhes << Detalhe400.parse(line, definition)
        end
      end

      Retorno.new({ :header_arquivo => header_arquivo,
                    :detalhes => detalhes,
                    :trailer_arquivo => trailer_arquivo  })
    end

  end

  def self.validate_missing_lines(file, num_lines)
    raise Exceptions::MissingLines if %x{wc -l #{file}}.scan(/[0-9]+/).first.to_i < num_lines
  end

  def self.root_path
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def self.config_path
    File.join(root_path, 'config')
  end
end