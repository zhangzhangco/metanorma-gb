require "spec_helper"
require "fileutils"
require "relaton_gb"

RSpec.describe Metanorma::Gb do
  it "ok has a version number" do
    expect(Metanorma::Gb::VERSION).not_to be nil
  end

  it "processes a blank document" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</gb-standard>
    OUTPUT
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.pdf"
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :language: en
      :script: Latn
    INPUT
    #{BLANK_HDR}
<sections/>
</gb-standard>
    OUTPUT
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("test.pdf")).to be true
    expect(File.exist?("htmlstyle.css")).to be false
  end

  it "uses Roman fonts" do
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Latn
      :no-pdf:

    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[body[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Calibri", sans-serif;]m)
    expect(html).to match(%r[\.standard_class[^{]+\{[^{]+font-family: "Cambria", serif;]m)
  end

  it "uses Roman fonts, local scope" do
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Latn
      :scope: local
      :no-pdf:

    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[body[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Calibri", sans-serif;]m)
    expect(html).to match(%r[\.standard_class[^{]+\{[^{]+font-family: "Calibri", sans-serif;]m)
  end

  it "uses default Chinese fonts" do
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:

    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[body[^{]+\{[^{]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "SimHei", sans-serif;]m)
    expect(html).to match(%r[\.standard_class[^{]+\{[^{]+font-family: "SimSun", serif;]m)
  end

  it "uses Chinese fonts, local scope" do
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :scope: local
      :no-pdf:

    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[body[^{]+\{[^{]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "SimHei", sans-serif;]m)
    expect(html).to match(%r[\.standard_class[^{]+\{[^{]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
      :title-font: Symbol
      :no-pdf:

    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[body[^{]+\{[^{]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: Comic Sans;]m)
    expect(html).to match(%r[\.standard_class[^{]+\{[^{]+font-family: Symbol;]m)
  end

  it "uses specified images" do
    Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :standard-logo-img: spec/asciidoctor/examples/a.gif
      :standard-class-img: spec/asciidoctor/examples/b.gif
      :standard-issuer-img: spec/asciidoctor/examples/c.gif
      :no-pdf:

    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match %r{<div class="coverpage-logo-gb-img"><img class="logo" width="113" height="56" src="test.htmlimages/[^\.]+.gif" alt="GB" /></div>}
    expect(html).to match %r{<span class="coverpage-logo-text"><img class="logo" src="test.htmlimages/[^\.]+.gif" alt="&#x4E2D;&#x534E;&#x4EBA;&#x6C11;&#x5171;&#x548C;&#x56FD;&#x56FD;&#x5BB6;&#x6807;&#x51C6;" width="18" height="18" /></span>}
    expect(html).to match %r{<img class="logo" src="test.htmlimages/[^\.]+.gif" alt="&#x4E2D;&#x534E;&#x4EBA;&#x6C11;&#x5171;&#x548C;&#x56FD;&#x56FD;&#x5BB6;&#x8D28;&#x91CF;&#x76D1;&#x7763;&#x68C0;&#x9A8C;&#x68C0;&#x75AB;&#x603B;&#x5C40;,&#x4E2D;&#x56FD;&#x56FD;&#x5BB6;&#x6807;&#x51C6;&#x5316;&#x7BA1;&#x7406;&#x59D4;&#x5458;&#x4F1A;" width="18" height="18" />}
  end

  it "does contributor cleanup" do
    FileUtils.rm_f "test.doc"
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :nodoc:
      :language: en
      :script: Latn
      :scope: sector
      :prefix: NY
      :docnumber: 123
      :technical-committee-type: Governance
      :technical-committee: Technical


    INPUT
           <?xml version="1.0" encoding="UTF-8"?>
       <gb-standard xmlns="https://www.metanorma.org/ns/gb"  type="semantic" version="#{Metanorma::Gb::VERSION}">
       <bibdata type="standard">
         <docidentifier type="gb">NY 123</docidentifier>
         <docnumber>123</docnumber>
         <contributor>
           <role type="author"/>
           <person>
             <name>
               <surname>Author</surname>
             </name>
           </person>
         </contributor><contributor><role type="technical-committee"/><organization><name>Technical</name></organization></contributor>
         <contributor>
           <role type="author"/>
           <organization>
             <name>GB</name>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>GB</name>
           </organization>
         </contributor>
         <contributor>
           <role type="authority"/>
           <organization>
             <name>GB</name>
           </organization>
         </contributor>
         <contributor>
           <role type="proposer"/>
           <organization>
             <name>GB</name>
           </organization>
         </contributor>
         <contributor>
           <role type="issuer"/>
           <organization>
             <name>Ministry of Agriculture</name>
           </organization>
         </contributor>
         <language>en</language>
         <script>Latn</script>
         <status>
           <stage abbreviation="IS">60</stage>
           <substage>60</substage>
         </status>
         <copyright>
           <from>#{Date.today.year}</from>
           <owner>
             <organization>
               <name>Ministry of Agriculture</name>
             </organization>
           </owner>
         </copyright>
         <ext>
        <doctype>standard</doctype>
         <gbcommittee type="Governance">Technical</gbcommittee>
         <structuredidentifier>
           <project-number>NY 123</project-number>
         </structuredidentifier>
         <stagename>International standard</stagename>
         <gbtype>
           <gbscope>sector</gbscope>
           <gbprefix>NY</gbprefix>
           <gbmandate>mandatory</gbmandate>
           <gbtopic>basic</gbtopic>
         </gbtype>
         </ext>
       </bibdata>
       <boilerplate> </boilerplate>
       <sections/>
       </gb-standard>
    OUTPUT
  end

    it "strips any initial boilerplate from terms and definitions" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
    #{BLANK_HDR}
              <sections>
         <terms id="_" obligation="normative"><title>Terms and definitions</title>
         <p id="_">For the purposes of this document,
           the following terms and definitions apply.</p>
       <p id="_">ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul id="_">
       <li> <p id="_">ISO Online browsing platform: available at
         <link target="http://www.iso.org/obp"/></p> </li>
       <li> <p id="_">IEC Electropedia: available at
       <link target="http://www.electropedia.org"/>
       </p> </li> </ul>
       <term id="term-time">
         <preferred language="zh"></preferred> <preferred language="en">Time</preferred>
         <definition><p id="_">This paragraph is extraneous</p></definition>
       </term></terms>
       </sections>
       </gb-standard>
    OUTPUT
  end

    it "does not strip any initial boilerplate from terms and definitions if keep-boilerplate attribute" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :keep-boilerplate:
      :language: en
      :script: Latn

      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
    #{BLANK_HDR}
              <sections>
         <terms id="_" obligation="normative"><title>Terms and definitions</title><p id="_">I am boilerplate</p>
       <ul id="_">
         <li>
           <p id="_">So am I</p>
         </li>
       </ul>
       <term id="term-time">
         <preferred language="zh"></preferred> <preferred language="en">Time</preferred>
         <definition><p id="_">This paragraph is extraneous</p></definition>
       </term></terms>
       </sections>
       </gb-standard>
    OUTPUT
  end

  it "processes ISO inline_quoted formatting" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      _emphasis_
      *strong*
      `monospace`
      "double quote"
      'single quote'
      super^script^
      sub~script~
      stem:[a_90]
      stem:[<mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [alt]#alt#
      [deprecated]#deprecated#
      [domain]#domain#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT
    #{BLANK_HDR}

       <sections>
         <em>emphasis</em>
       <strong>strong</strong>
       <tt>monospace</tt>
       “double quote”
       ‘single quote’
       super<sup>script</sup>
       sub<sub>script</sub>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>a</mi>
</mrow>
<mrow>
  <mn>90</mn>
</mrow>
</msub></math></stem>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
       <admitted language="zh"></admitted> <admitted language="en">alt</admitted>
       <deprecates language="zh"></deprecates> <deprecates language="en">deprecated</deprecates>
       <domain>domain</domain>
       <strike>strike</strike>
       <smallcap>smallcap</smallcap>
       </sections>
       </gb-standard>
    OUTPUT
  end

  it "processes GB inline_quoted formatting" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}

    [en]#en#
    [zh]#zh#
    [zh-Hans]#zh-Hans#
    [zh-Hant]#zh-Hant#
    INPUT
    #{BLANK_HDR}
       <sections>
       <p id="_"><string language="en">en</string>
       <string language="zh">zh</string>
       <string language="zh" script="Hans">zh-Hans</string>
       <string language="zh" script="Hant">zh-Hant</string></p>
       </sections>
       </gb-standard>
    OUTPUT
  end

  it "extracts localised strings by content" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}
    [deprecated]#deprecated 被取代#
    INPUT
    #{BLANK_HDR}
       <sections>
       <deprecates language="zh">被取代</deprecates> <deprecates language="en">deprecated</deprecates>
       </sections>
       </gb-standard>
    OUTPUT
  end

  it "extracts tagged localised strings" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Bibliography

      * [[[xiso123,XISO 123]]] _a_ [zh]#A# [en]#B#
    INPUT
       #{BLANK_HDR}
<sections>

       </sections><bibliography><references id="_" obligation="informative" normative="false">
         <title>Bibliography</title>
         <bibitem id="xiso123">
         <em>a</em> <formattedref language="zh">A</formattedref> <formattedref language="en">B</formattedref>
         <docidentifier>XISO 123</docidentifier>
         <docnumber>123</docnumber>
       </bibitem>
       </references></bibliography>
       </gb-standard>
    OUTPUT
  end

    it "fetches simple GB reference in English" do
    mock_gbbib_get_123("en")
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ISOBIB_BLANK_HDR}

      <<iso123>>

      [bibliography]
      == Normative References

      * [[[iso123,GB/T 20223-2006]]] _Standard_
    INPUT
      #{BLANK_HDR}
      <preface><foreword id="_" obligation="informative">
  <title>Foreword</title>
  <p id="_">
  <eref type="inline" bibitemid="iso123" citeas="GB/T 20223"/>
</p>
</foreword></preface>
      <sections>
             </sections><bibliography><references id="_" obligation="informative" normative="true">
         <title>Normative references</title>
         <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      #{GBT20223.sub(%{id="GB/T20223"}, %{id="iso123"}).sub(%r{<title format="text/plain" language="zh".+?</title>}, "")}
       </references></bibliography>
       </gb-standard>
    OUTPUT
    end

     it "fetches simple GB reference in Chinese" do
    mock_gbbib_get_123("zh")
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)).sub(%r{<bibdata.*</bibdata>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ISOBIB_BLANK_HDR_ZH}

      <<iso123>>

      [bibliography]
      == Normative References

      * [[[iso123,GB/T 20223-2006]]] _Standard_
    INPUT
       <gb-standard xmlns="https://www.metanorma.org/ns/gb"  type="semantic" version="#{Metanorma::Gb::VERSION}">
         <boilerplate> </boilerplate>
         <preface>
           <foreword id='_' obligation='informative'>
             <title>前言</title>
             <p id='_'>
               <eref type='inline' bibitemid='iso123' citeas='GB/T 20223'/>
             </p>
           </foreword>
         </preface>
      <sections>
             </sections><bibliography><references id="_" obligation="informative" normative="true">
         <title>规范性引用文件</title>
         <p id="_">下列文件对于本文件的应用是必不可少的。 凡是注日期的引用文件，仅注日期的版本适用于本文件。
凡是不注日期的引用文件，其最新版本（包括所有的修改单）适用于本文件。</p>
      #{GBT20223.sub(%{id="GB/T20223"}, %{id="iso123"}).sub(%r{<title format="text/plain" language="en".+?</title>}, "")}
       </references></bibliography>
       </gb-standard>
    OUTPUT
    end


    private

    def mock_gbbib_get_123(lang)
      expect(RelatonGb::GbBibliography).to receive(:get).with("GB/T 20223", "2006", {:lang=>lang, :title=>"<em>Standard</em>", :usrlbl=>nil}) do
        RelatonIsoBib::XMLParser.from_xml(GBT20223)
      end
    end
end
