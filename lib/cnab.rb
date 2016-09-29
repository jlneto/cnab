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
  autoload :CnabWriter, 'cnab/cnab_writer'

  autoload :Exceptions, 'cnab/exceptions'

  def self.parse(file = nil, merge = false, version = nil)
    raise Exceptions::NoFileGiven if file.nil?

    unless version
      cnab_type = detect_cnab_type(file)
      if cnab_type[0] == 400
        if cnab_type[1] == 'REM'
          version = 'itau_400'
        else
          version = 'itau_400_retorno'
        end
      else
        version = '08.7'
      end
    end

    if cnab_type[0] < 245
      parse_240(file, version, merge)
    else
      parse_400(file, version, merge )
    end
  end

  def self.detect_cnab_type(file)
    size = 400
    tipo = 'REM'
    banco = 'CNAB'
    File.open(file, 'rb') do |f|
      first_line = f.gets
      if first_line.size < 245
        size = 240
      end
      if first_line.include?( 'RETORNO' )
        tipo = 'RET'
      end
      if first_line.include?( 'ITAU' )
        banco = 'ITAU'
      end
    end
    [size, tipo, banco]
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