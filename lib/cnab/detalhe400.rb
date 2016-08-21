module Cnab
  module Detalhe400
    def self.parse(line, definition)
      case line[0]
        when '1'
          Line.new(line, definition.detalhe)
        when '2'
          Line.new(line, definition.detalhe_complemento)
        else
          raise Exceptions::SegmentNotImplemented
      end
    end

    def self.merge(line1, line2, definition)
      MergedLines.new(parse(line1, definition), parse(line2, definition))
    end
  end
end