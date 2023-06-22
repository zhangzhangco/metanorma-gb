require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "metanorma/gb/converter"
require_relative "metanorma/gb/version"
require_relative "isodoc/gb/common"
require_relative "isodoc/gb/html_convert"
require_relative "isodoc/gb/word_convert"
require_relative "isodoc/gb/pdf_convert"
require_relative "isodoc/gb/presentation_xml_convert"

if defined? Metanorma
  require_relative "metanorma/gb"
  Metanorma::Registry.instance.register(Metanorma::Gb::Processor)
end
