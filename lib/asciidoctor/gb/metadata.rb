require "isodoc"

module Asciidoctor
  module Gb
    # A {Converter} implementation that generates GB output, and a document
    # schema encapsulation of the document for validation
    class GbConvert < IsoDoc::Convert
      def init_metadata
        super
        set_metadata(:docmaintitlezh, "XXXX")
        set_metadata(:docsubtitlezh, "")
        set_metadata(:docparttitlezh, "")
        set_metadata(:docmaintitleen, "XXXX")
        set_metadata(:docsubtitleen, "")
        set_metadata(:docparttitleen, "")
      end

      def title(isoxml, _out)
        intro = isoxml.at(ns("//title-intro[@language='zh']"))
        main = isoxml.at(ns("//title-main[@language='zh']"))
        part = isoxml.at(ns("//title-part[@language='zh']"))
        partnumber = isoxml.at(ns("//project-number/@part"))
        set_metadata(:docmaintitlezh, intro.text + "&mdash;") unless intro.nil?
        set_metadata(:docsubtitlezh, main.text)
        partnum = partnumber ? "#{part_label(partnumber, 'zh')}: " : ""
        set_metadata(:docparttitlezh, "&mdash;#{partnum} #{part.text}") unless part.nil?
      end

      def subtitle(isoxml, _out)
        intro = isoxml.at(ns("//title-intro[@language='en']"))
        main = isoxml.at(ns("//title-main[@language='en']"))
        part = isoxml.at(ns("//title-part[@language='en']"))
        partnumber = isoxml.at(ns("//project-number/@part"))
        set_metadata(:docmaintitleen, intro.text + "&mdash;") unless intro.nil?
        set_metadata(:docsubtitleen, main.text)
        partnum = partnumber ? "#{part_label(partnumber, 'en')}: " : ""
        set_metadata(:docparttitleen, "&mdash;#{partnum} #{part.text}") unless part.nil?
      end

      def author(isoxml, _out)
        gbcommittee = isoxml.at(ns("//bibdata/gbcommittee"))
        set_metadata(:committee, gbcommittee.text)
      end

      def id(isoxml, _out)
        super
        gb_identifier(isoxml)
        gb_library_identifier(isoxml)
      end

      def gb_identifier(isoxml)
        gbscope = isoxml.at(ns("//gbscope"))&.text || "national"
        gbmandate = isoxml.at(ns("//gbmandate"))&.text || "mandatory"
        gbprefix = isoxml.at(ns("//gbprefix"))&.text || "XXX"
        dn = "#{mandate_suffix(gbprefix, gbmandate)} #{get_metadata()[:docnumber]}"
        set_metadata(:docidentifier, dn)
        set_metadata(:standard_class, standard_class(gbscope, gbprefix, gbmandate))
        set_metadata(:standard_agency, standard_agency(gbscope, gbprefix, gbmandate))
        set_metadata(:gbprefix, gbprefix)
      end

      def standard_logo(gbprefix)
        case gbprefix.downcase
        when "db" then "html/gb-standard-db"
        when "gb" then "html/gb-standard-gb"
        when "gjb" then "html/gb-standard-gjb"
        when "gjb" then "html/gb-standard-gjb"
        when "gm" then "html/gb-standard-gm"
        when "jjf" then "html/gb-standard-jjf"
        when "zb" then "html/gb-standard-zb"
        else
          nil
        end
      end

      def gb_library_identifier(isoxml)
        ics = isoxml.at(ns("//gblibraryids/ics"))
        l = isoxml.at(ns("//gblibraryids/l"))
        set_metadata(:libraryid_ics, ics ? ics.text : "XXX")
        set_metadata(:libraryid_l, l ? l.text : "XXX")
      end

      def part_label(partnumber, lang)
        case lang
        when "en" then "Part #{partnumber}"
        when "zh" then "第#{partnumber}部"
        end
      end

      def format_logo(prefix, format)
        logo = standard_logo(prefix)
        if logo.nil?
          "<span style='font-size:36pt;font-weight:bold'>#{prefix}</span>"
        else
          logo += (format == :html ? ".png" : ".svg")
          system "cp #{File.join(File.dirname(__FILE__), File.join("html", logo))} #{logo}"
          logo
        end
      end

      def populate_template(docxml, format)
        meta = get_metadata
        logo = format_logo(meta[:gbprefix], format)
        docxml.
          gsub(/DOCYEAR/, meta[:docyear]).
          gsub(/DOCNUMBER/, meta[:docnumber]).
          gsub(/DOCIDENTIFIER/, meta[:docidentifier]).
          gsub(/COMMITTEE/, meta[:committee]).
          gsub(/DOCMAINTITLEZH/, meta[:docmaintitlezh]).
          gsub(/DOCSUBTITLEZH/, meta[:docsubtitlezh]).
          gsub(/DOCPARTTITLEZH/, meta[:docparttitlezh]).
          gsub(/DOCMAINTITLEEN/, meta[:docmaintitleen]).
          gsub(/DOCSUBTITLEEN/, meta[:docsubtitleen]).
          gsub(/DOCPARTTITLEEN/, meta[:docparttitleen]).
          gsub(/PUBDATE/, meta[:publisheddate]).
          gsub(/ACTIVEDATE/, meta[:activateddate]).
          gsub(/LIBRARYID_ICS/, meta[:libraryid_ics]).
          gsub(/LIBRARYID_L/, meta[:libraryid_l]).
          gsub(/STANDARD_CLASS/, meta[:standard_class]).
          gsub(/STANDARD_AGENCY/, meta[:standard_agency]).
          gsub(/LIBRARYID_L/, meta[:libraryid_l]).
          gsub(/STANDARD_LOGO/, logo).
          gsub(/[ ]?DRAFTINFO/, meta[:draftinfo]).
          gsub(/\[TERMREF\]\s*/, "[SOURCE: "). # TODO: Chinese
          gsub(/\s*\[\/TERMREF\]\s*/, "]").
          gsub(/\s*\[ISOSECTION\]/, ", 定义").
          gsub(/\s*\[MODIFICATION\]/, ", 改写 &mdash; ").
          gsub(%r{WD/CD/DIS/FDIS}, meta[:stageabbr])
      end

      STAGE_ABBRS = {
        "00": "PWI",
        "10": "NWIP",
        "20": "WD",
        "30": "CD",
        "40": "DIS",
        "50": "FDIS",
        "60": "IS",
        "90": "(Review)",
        "95": "(Withdrawal)",
      }.freeze
    end
  end
end
