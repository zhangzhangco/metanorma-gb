require_relative "init"
require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Gb
    # A {Converter} implementation that generates GB output, and a document
    # schema encapsulation of the document for validation
    class HtmlConvert < IsoDoc::HtmlConvert
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
          titlefont: options[:titlefont] || default_font_options[:titlefont]
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: options[:compliant] ? html_doc_path("htmlcompliantstyle.scss") : html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_compliant_gb_titlepage.html"),
          htmlintropage: html_doc_path("html_gb_intro.html"),
          scripts: html_doc_path("scripts.html"),
        }
      end

      def populate_template(docxml, format)
        meta = @meta.get.merge(@i18n.get).merge(@meta.fonts_options || {})
        logo = @common.format_logo(meta[:gbprefix], meta[:gbscope], format, @localdir)
        logofile = @meta.standard_logo(meta[:gbprefix])
        meta[:standard_agency_formatted] =
          @common.format_agency(meta[:standard_agency], format, @localdir)
        meta[:standard_logo] = logo
        template = Liquid::Template.parse(docxml)
        template.render(meta.map { |k, v| [k.to_s, v] }.to_h)
      end

      def insert_tab(out, n)
        tab = "&#x3000;"
        [1..n].each { out << tab }
      end

      include BaseConvert
      include Init
    end
  end
end
