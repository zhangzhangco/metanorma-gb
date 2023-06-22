require_relative "front_id"

module Metanorma
  module Gb
    class Converter < ISO::Converter
      def get_mandate(node)
        node.attr("mandate") and return node.attr("mandate")
        p = node.attr("prefix")
        mandate = %r{/T}.match(p) ? "recommended" :
          %r{/Z}.match(p) ? "recommended" : nil
        if mandate.nil?
          mandate = "mandatory"
          @log.add("Document Attributes", nil, "GB: no mandate supplied, defaulting to mandatory")
        end
        mandate
      end

      def get_scope(node)
        node.attr("scope") and return node.attr("scope")
        scope = if %r{^[TQ]/}.match node.attr("prefix")
                  m = node.attr("prefix").split(%{/})
                  mandate = m[0] == "T" ? "social-group" :
                    m[0] == "Q" ? "enterprise" : nil
                end
        return scope unless scope.nil?
        @log.add("Document Attributes", nil, "GB: no scope supplied, defaulting to National")
        "national"
      end

      def get_prefix(node)
        scope = get_scope(node)
        if prefix = node.attr("prefix")
          prefix.gsub!(%r{/[TZ]$}, "")
          prefix.gsub!(%r{^[TQ]/([TZ]/)?}, "")
          prefix.gsub!(/^DB/, "") if scope == "local"
        else
          prefix = "GB"
          scope = "national"
          @log.add("Document Attributes", nil, "GB: no prefix supplied, defaulting to GB")
        end
        [scope, prefix]
      end

      def title_full(node, xml, lang, at)
        title = node.attr("title-main-#{lang}")
        intro = node.attr("title-intro-#{lang}")
        part = node.attr("title-part-#{lang}")
        title = "#{intro} -- #{title}" if intro
        title = "#{title} -- #{part}" if part
        xml.title **attr_code(at.merge(type: "main")) do |t1|
          t1 << Metanorma::Utils::asciidoc_sub(title)
        end
      end

      def title(node, xml)
        ["en", "zh"].each do |lang|
          at = { language: lang, format: "plain" }
          title_full(node, xml, lang, at)
          title_intro(node, xml, lang, at)
          title_main(node, xml, lang, at)
          title_part(node, xml, lang, at)
        end
      end

      def metadata_mandate(node, xml)
        mandate = node.attr("mandate") || return
        xml.mandate mandate
      end

      def metadata_author_personal(node, xml)
        author = node.attr("author") || return
        author.split(/, ?/).each do |author|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.person do |p|
              p.name  author
            end
          end
        end
      end

      def metadata_drafting_body(node, xml)
        draftingbody = node.attr("drafting-body") || return
        draftingbody.split(/, ?/).each do |draftingbody|
          xml.contributor do |c|
            c.role **{ type: "drafting-body" }
            c.draftingbody do |p|
              p.name  draftingbody
            end
          end
        end
      end

      def metadata_contributor1(node, xml, type, role)
        contrib = node.attr(type) || return
        contrib.split(/, ?/).each do |c|
          xml.contributor do |x|
            x.role **{ type: role }
            x.organization do |a|
              a.name { |n| n << c }
            end
          end
        end
      end

      def metadata_copyright(node, xml)
        from = node.attr("copyright-year") || Date.today.year
        xml.copyright do |c|
          c.from from
          c.owner do |owner|
            owner.organization do |o|
              o.name "GB"
            end
          end
        end
      end

      def metadata_committee(node, xml)
        return unless node.attr("technical-committee")
        attrs = { type: node.attr("technical-committee-type"), number: node.attr("technical-committee-number")}
        xml.gbcommittee **attr_code(attrs) do |a|
          a << node.attr("technical-committee")
        end
        i = 2
        while node.attr("technical-committee_#{i}") do
          attrs = { type: node.attr("technical-committee-type_#{i}"), number: node.attr("technical-committee-number_#{i}") }
          xml.gbcommittee **attr_code(attrs) do |a|
            a << node.attr("technical-committee_#{i}")
          end
          i += 1
        end
      end

      def metadata_equivalence(node, xml)
        adpstd = node.attr("adoption-title") || return
        type = node.attr("adoption-type") || "IDT"
        m = /^(?<code>[^,]+),?(?<title>.*)$/.match adpstd
        title = m[:title].empty? ? "[not supplied]" : m[:title]
        xml.relation **{ type: "adoptedFrom" } do |r|
          r.description type
          r.bibitem do |b|
            b.title { |t| t << title }
            b.docidentifier m[:code]
          end
        end
      end

      def metadata_relations(node, xml)
        metadata_equivalence(node, xml)
        metadata_obsoletes(node, xml)
      end

      def metadata_obsoletes(node, xml)
        std = node.attr("obsoletes") || return
        m = /^(?<code>[^,]+),?(?<title>.*)$/.match std
        title = m[:title].empty? ? "[not supplied]" : m[:title]
        xml.relation **{ type: "obsoletes" } do |r|
          r.bibitem do |b|
            b.title { |t| t << title }
            b.docidentifier m[:code]
          end
          r.bpart node.attr("obsoletes-parts") if node.attr("obsoletes-parts")
        end
      end

      def get_topic(node)
        node.attr("topic") and return node.attr("topic")
        @log.add("Document Attributes", nil, "GB: no topic supplied, defaulting to basic")
        "basic"
      end

      def metadata_gbtype(node, xml)
        xml.gbtype do |t|
          scope, prefix = get_prefix(node)
          t.gbscope { |s| s << scope }
          t.gbprefix { |p| p << prefix }
          t.gbmandate { |m| m << get_mandate(node) }
          t.gbtopic { |t| t << get_topic(node) }
        end
      end

      def metadata_gblibraryids(node, xml)
        ccs = node.attr("library-ccs")
        ccs and ccs.split(/, ?/).each do |l|
          xml.ccs { |c| c << l }
        end
        l = node.attr("library-plan")
        l && xml.plannumber { |plan| plan << l }
      end

      def metadata_author(node, xml)
        metadata_author_personal(node, xml)
        metadata_drafting_body(node, xml)
      end

      def metadata_publisher(node, xml)
        metadata_contributor1(node, xml, "proposer", "proposer")
        metadata_contributor1(node, xml, "mirror-body", "mirror-body")
        metadata_contributor1(node, xml, "announcing-body", "announcing-body")
      end

      def metadata_language(node, xml)
        xml.language (node.attr("language") || "zh")
      end

      def metadata_script(node, xml)
        xml.script (node.attr("script") || "Hans")
      end

      def metadata_doctype(node, xml)
        p = node.attr("prefix")
        xml.doctype %r{/Z}.match(p) ? "technical-document" :
                      "standard"

      end

      def metadata_ext(node, xml)
        metadata_doctype(node, xml)
        metadata_committee(node, xml)
        metadata_ics(node, xml)
        metadata_gblibraryids(node, xml)
        structured_id(node, xml)
        xml.stagename stage_name(get_stage(node), get_substage(node))
        metadata_gbtype(node, xml)
      end
    end
  end
end
