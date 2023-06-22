require "relaton_gb"
require "metanorma"
require "metanorma/iso/converter"

module Metanorma
  module Gb

    # A {Converter} implementation that generates GB output, and a document
    # schema encapsulation of the document for validation
    class Converter < ::Metanorma::ISO::Converter
      def sectiontype_streamline(ret)
        case ret
        when "前言" then "foreword"
        when "引言" then "introduction"
        when "范围" then "scope"
        when "规范性引用文件" then "normative references"
        when "术语和定义" then "terms and definitions"
        when "符号和缩略语" then "symbols and abbreviated terms"
        when "参考文献" then "bibliography"
        else
          super
        end
      end

      def symbols_attrs(node, a)
        case sectiontype1(node)
        when "符号" then a.merge(type: "symbols")
        when "代号和缩略语" then a.merge(type: "abbreviated_terms")
        else
          super
        end
      end

      def appendix_parse(attrs, xml, node)
        # UNSAFE, there is no unset_option() in asciidoctor
        node.remove_attr("appendix-option")
        clause_parse(attrs, xml, node)
      end
    end
  end
end
