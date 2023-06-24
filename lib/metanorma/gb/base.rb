module Metanorma
  module Gb
    # A {Converter} implementation that generates GB output, and a document
    # schema encapsulation of the document for validation
    class Converter < ISO::Converter
      XML_ROOT_TAG = "gb-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/gb".freeze

      def html_converter(node)
        IsoDoc::Gb::HtmlConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::Gb::WordConvert.new(doc_extract_attributes(node))
      end

      def gb_attributes(node)
        {
          libraryplan: node.attr("library-plan"),
          standardlogoimg: node.attr("standard-logo-img"),
          standardclassimg: node.attr("standard-class-img"),
          standardissuerimg: node.attr("standard-issuer-img"),
          titlefont: node.attr("title-font"),
        }
      end

      def html_extract_attributes(node)
        super.merge(gb_attributes(node))
      end

      def doc_extract_attributes(node)
        super.merge(gb_attributes(node)).merge(gbwordtemplate: node.attr("gb-word-template"),
                    gbwordbgstripcolor: node.attr("gb-word-bg-strip-color"))
      end

      def pdf_converter(node)
        return nil if node.attr("no-pdf")
        IsoDoc::Gb::PdfConvert.new(pdf_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::Gb::PresentationXMLConvert.new(html_extract_attributes(node))
      end

      def html_compliant_converter(node)
        IsoDoc::Gb::HtmlConvert.new(html_extract_attributes(node).merge(compliant: true))
      end

      def init(node)
        node.attr("language") or node.set_attr("language", "zh")
        node.attr("script") or
          node.set_attr("script", node.attr("language") == "zh" ?
                        "Hans" : "Latn")
        super
      end

      def outputs(node, ret)
        File.open(@filename + ".xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node).convert(@filename + ".xml")
        html_compliant_converter(node).convert(@filename + ".presentation.xml",
                  nil, false, "#{@filename}_compliant.html")
        html_converter(node).convert(@filename + ".presentation.xml",
                                     nil, false, "#{@filename}.html")
        doc_converter(node).convert(@filename + ".presentation.xml",
                                    nil, false, "#{@filename}.doc")
        #pdf_converter(node)&.convert(@filename + ".presentation.xml",
        #                             nil, false, "#{@filename}.pdf")
      end
    end
  end
end
