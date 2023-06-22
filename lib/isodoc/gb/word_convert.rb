require_relative "base_convert"
require "isodoc"
require_relative "init"

module IsoDoc
  module Gb
    # A {Converter} implementation that generates GB output, and a document
    # schema encapsulation of the document for validation
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @common = IsoDoc::Gb::Common.new(options)
        @standardclassimg = options[:standardclassimg]
        @libdir = File.dirname(__FILE__)
        super
        @lang = "zh"
        @script = "Hans"
      end

      def default_fonts(options)
        script = options[:script] || "Hans"
        scope = options[:scope] || "national"
        {
          bodyfont: (script == "Hans" ? '"SimSun",serif' : '"Cambria",serif'),
          headerfont: (script == "Hans" ? '"SimHei",sans-serif' : '"Calibri",sans-serif'),
          monospacefont: '"Courier New",monospace',
          titlefont: (scope == "national" ? (script != "Hans" ? '"Cambria",serif' : '"SimSun",serif' ) :
                      (script == "Hans" ? '"SimHei",sans-serif' : '"Calibri",sans-serif' )),
          normalfontsize: "1.0em",
          smallerfontsize: "0.9em",
          footnotefontsize: "0.9em",
          monospacefontsize: "0.8em",
        }
      end

      def fonts_options
        default_font_options = default_fonts(options)
        {
          bodyfont: options[:bodyfont] || default_font_options[:bodyfont],
          headerfont: options[:headerfont] || default_font_options[:headerfont],
          monospacefont: options[:monospacefont] || default_font_options[:monospacefont],
          titlefont: options[:titlefont] || default_font_options[:titlefont],
          normalfontsize: options[:normalfontsize] || default_font_options[:normalfontsize],
          smallerfontsize: options[:smallerfontsize] || default_font_options[:smallerfontsize],
          footnotefontsize: options[:footnotefontsize] || default_font_options[:footnotefontsize],
          monospacefontsize: options[:monospacefontsize] || default_font_options[:monospacefontsize],
        }
      end

      def default_file_locations(options)
        {
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("gb.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_gb_titlepage.html"),
          wordintropage: html_doc_path("word_gb_intro.html"),
          ulstyle: "l7",
          olstyle: "l10",
        }
      end

      ENDLINE = <<~END.freeze
      <v:line
 alt="" style='position:absolute;left:0;text-align:left;z-index:251662848;
 mso-wrap-edited:f;mso-width-percent:0;mso-height-percent:0;
 mso-width-percent:0;mso-height-percent:0'
 from="6.375cm,20.95pt" to="10.625cm,20.95pt"
 strokeweight="1.5pt"/>
      END

      def end_line(_isoxml, out)
        out.parent.add_child(ENDLINE)
      end

      def word_cleanup(docxml)
        @cleanup.title_cleanup(docxml.at('//div[@class="WordSection2"]'))
        super
      end

      def example_table_parse(node, out)
        out.table **attr_code(id: node["id"], class: "example") do |t|
          t.tr do |tr|
            tr.td **EXAMPLE_TBL_ATTR do |td|
              node.at(ns("./name")).children.each { |n| parse(n, td) }
            end
            tr.td **{ valign: "top", class: "example" } do |td|
              node.children.each { |n| parse(n, td) unless n.name == "name" }
            end
          end
        end
      end

      def populate_template(docxml, format)
        meta = @meta
          .get
          .merge(@i18n.get)
          .merge(@meta.fonts_options || {})
        logo = @common.format_logo(meta[:gbprefix], meta[:gbscope], format, @localdir)
        logofile = @meta.standard_logo(meta[:gbprefix])
        meta[:standard_agency_formatted] =
          @common.format_agency(meta[:standard_agency], format, @localdir)
        meta[:standard_logo] = logo
        template = liquid(docxml)
        template.render(meta.map { |k, v| [k.to_s, empty2nil(v)] }.to_h)
          .gsub('&lt;', '&#x3c;').gsub('&gt;', '&#x3e;').gsub('&amp;', '&#x26;')
      end

      def make_body(xml, docxml)
        body_attr = { lang: "ZH-CN", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
          colophon(body, docxml)
        end
      end

      # def convert(input_filename, file = nil, debug = false,
      #           output_filename = nil)
      #   file = File.read(input_filename, encoding: "utf-8") if file.nil?
      #   docxml = Nokogiri::XML(file) { |config| config.huge }
      #   stage = docxml&.at(ns("//bibdata/status/stage"))&.text
      #   if @dis &&
      #       ((/^[4569].$/.match?(stage) && @wordtemplate != "simple") ||
      #       (/^[0-3].$/.match?(stage) && @wordtemplate == "dis"))
      #     @dis.convert(input_filename, file, debug, output_filename)
      #   else
      #     super
      #   end
      # end

      def br(out, pagebreak)
        out.br clear: "all", style: "page-break-before:#{pagebreak};" \
                                    "mso-break-type:section-break"
      end

      def colophon(body, _docxml)
        stage = @meta.get[:stage_int]
        return if !stage.nil? && stage < 60

        br(body, "left")
        body.div class: "colophon" do |div|
        end
      end

      include BaseConvert
      include Init
    end
  end
end
