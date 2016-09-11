module Cnab

  class CnabWriter

    def initialize(version)
      @version = version
      @lines = []
      @definition = Cnab::Configs400.new(version)
    end

    def add_line(line_hash)
      line = create_line(line_hash)
      @lines << line
    end

    def to_file
      @lines.join("\n")
    end

    def definition(tipo_de_registro)
      case tipo_de_registro
        when '0'
          @definition.header_arquivo
        when '1'
          @definition.detalhe
        when '2'
          @definition.detalhe_complemento
        when '9'
          @definition.trailer_arquivo
      end
    end

    def create_line(line_hash)
      s = ''.rjust(400)
      line_layout = definition(line_hash['TIPO_DE_REGISTRO'])
      line_layout.fields.each do |key,value|
        range = value.split('|')
        p1 = range[1].strip.to_i - 1
        p2 = range[2].strip.to_i - 1
        hash_value = line_hash[key].to_s
        s[p1..p2] = hash_value.rjust(p2-p1+1)
      end
      s
    end
  end
end
