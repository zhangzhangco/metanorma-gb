require_relative "../spec_helper"

RSpec.describe Metanorma::Gb do
  it "processes national stdandard metadata" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = 数字电影LED影厅技术要求和测量方法
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :mandate: mandatory
      :library-ics: 11.060
      :library-ccs: N40
      :library-plan: 备案号
      :scope: national
      :prefix: GB
      :docnumber: 123
      :obsoletes: GB/T 123-1995
      :copyright-year: 2023
      :title-intro-zh: 数字电影
      :title-main-zh: LED影厅
      :title-part-zh: 技术要求和测量方法
      :title-intro-en: Digital cinema
      :title-main-en: LED screen
      :title-part-en: Technical requirements and test methods
      :adoption-type: nonequivalent
      :adoption-title: ISO/IEC 1234:2001,LED Standard
      :published-date: 2024-01-01
      :implemented-date: 2024-03-01
      :issuer: 发布机构
      :technical-committee-type: TC
      :technical-committee-number: 586
      :technical-committee: 全国电影标准化技术专业委员会
      :proposer: 提出单位
      :author: 李娜,董强国,刘知一,张伟,龚波,高五峰,高峰,高峰,张辉,王景宇,贾波,周永业,董志刚,张鹏昊,张硕
      :imagesdir: 图片所在目录
    INPUT
    output = <<~OUTPUT
    <?xml version="1.0" encoding="UTF-8"?>
    <gb-standard type="semantic" version="2.0.1" xmlns="https://www.metanorma.org/ns/gb">
        <bibdata type="standard">
            <title format="plain" language="en" type="main">
                Digital cinema — LED screen — Technical requirements and test methods
            </title>
            <title format="plain" language="en" type="title-intro">
                Digital cinema
            </title>
            <title format="plain" language="en" type="title-main">
                LED screen
            </title>
            <title format="plain" language="en" type="title-part">
                Technical requirements and test methods
            </title>
            <title format="plain" language="zh" type="main">
                数字电影 — LED影厅 — 技术要求和测量方法
            </title>
            <title format="plain" language="zh" type="title-intro">
                数字电影
            </title>
            <title format="plain" language="zh" type="title-main">
                LED影厅
            </title>
            <title format="plain" language="zh" type="title-part">
                技术要求和测量方法
            </title>
            <docidentifier type="gb">
                123
            </docidentifier>
            <docnumber>
                123
            </docnumber>
            <date type="published">
                <on>
                    2024-01-01
                </on>
            </date>
            <contributor>
                <role type="author">
                </role>
                <person>
                    <name>
                        李娜,董强国,刘知一,张伟,龚波,高五峰,高峰,高峰,张辉,王景宇,贾波,周永业,董志刚,张鹏昊,张硕
                    </name>
                </person>
            </contributor>
            <contributor>
                <role type="proposer">
                </role>
                <organization>
                    <name>
                        提出单位
                    </name>
                </organization>
            </contributor>
            <language>
                zh
            </language>
            <script>
                Hans
            </script>
            <status>
                <stage>
                    60
                </stage>
                <substage>
                    60
                </substage>
            </status>
            <copyright>
                <from>
                    2023
                </from>
                <owner>
                    <organization>
                        <name>
                            GB
                        </name>
                    </organization>
                </owner>
            </copyright>
            <relation type="adoptedFrom">
                <description>
                    NEQ
                </description>
                <bibitem>
                    <title>
                        [not supplied]
                    </title>
                    <docidentifier>
                        ISO/IEC LED Standard
                    </docidentifier>
                </bibitem>
            </relation>
            <ext>
                <doctype>
                    standard
                </doctype>
                <gbcommittee number="586" type="TC">
                    全国电影标准化技术专业委员会
                </gbcommittee>
                <ics>
                    <code>
                        11.060
                    </code>
                    <text>
                        Dentistry
                    </text>
                </ics>
                <ccs>
                    N40
                </ccs>
                <plannumber>
                    备案号
                </plannumber>
                <structuredidentifier>
                    <project-number>
                        123
                    </project-number>
                </structuredidentifier>
                <stagename>
                    现行标准
                </stagename>
                <gbtype>
                    <gbscope>
                        国家
                    </gbscope>
                    <gbprefix>
                        GB
                    </gbprefix>
                    <gbmandate>
                        推荐性
                    </gbmandate>
                    <gbtopic>
                        basic
                    </gbtopic>
                </gbtype>
            </ext>
        </bibdata>
        <sections>
        </sections>
    </gb-standard>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(xmlpp(strip_guid(xml.to_xml)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :mandate: recommendation
      :iso-standard: ISO 1012, Televisual Frequencies
      :equivalence: nonequivalent
      :prefix: T/AAA
      :docnumber: 123
      :language: en
      :script: Latn
      :nodoc:
      :novalid:

    INPUT
    <?xml version="1.0" encoding="UTF-8"?>
       <gb-standard xmlns="https://www.metanorma.org/ns/gb"  type="semantic" version="#{Metanorma::Gb::VERSION}">
       <bibdata type="standard">
         <docidentifier type="gb">T/AAA 123</docidentifier>
<docnumber>123</docnumber>
         <contributor>
           <role type="author"/>
           <person>
             <name>
               <surname>Author</surname>
             </name>
           </person>
         </contributor>
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
             <name>GB</name>
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
               <name>GB</name>
             </organization>
           </owner>
         </copyright>
         <relation type="adoptedFrom">
           <description>nonequivalent</description>
           <bibitem>
             <title> Televisual Frequencies</title>
             <docidentifier>ISO 1012</docidentifier>
           </bibitem>
         </relation>
         <ext>
         <doctype>recommendation</doctype>
<structuredidentifier>
  <project-number>T/AAA 123</project-number>
</structuredidentifier>
<stagename>International standard</stagename>
         <gbtype>
           <gbscope>social-group</gbscope>
           <gbprefix>AAA</gbprefix>
           <gbmandate>recommendation</gbmandate>
           <gbtopic>basic</gbtopic>
         </gbtype>
         </ext>
       </bibdata>
       <boilerplate> </boilerplate>
       <sections/>
       </gb-standard>
    OUTPUT
  end

  it "processes metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :prefix: Q/Z/BBB
      :docnumber: 123
      :nodoc:
      :novalid:

    INPUT
    <?xml version="1.0" encoding="UTF-8"?>
       <gb-standard xmlns="https://www.metanorma.org/ns/gb"  type="semantic" version="#{Metanorma::Gb::VERSION}">
       <bibdata type="standard">
         <docidentifier type="gb">Q/BBB 123</docidentifier>
<docnumber>123</docnumber>
         <contributor>
           <role type="author"/>
           <person>
             <name>
               <surname>Author</surname>
             </name>
           </person>
         </contributor>
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
             <name>GB</name>
           </organization>
         </contributor>
         <language>zh</language>
         <script>Hans</script>
         <status>
           <stage abbreviation="IS">60</stage>
           <substage>60</substage>
         </status>
         <copyright>
           <from>#{Date.today.year}</from>
           <owner>
             <organization>
               <name>GB</name>
             </organization>
           </owner>
         </copyright>
         <ext>
         <doctype>standard</doctype>
<structuredidentifier>
  <project-number>Q/BBB 123</project-number>
</structuredidentifier>
<stagename>国家标准</stagename>
         <gbtype>
           <gbscope>enterprise</gbscope>
           <gbprefix>BBB</gbprefix>
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

  it "processes metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :mandate: guide
      :docnumber: 123
      :nodoc:
      :novalid:
      :language: en
      :script: Latn

    INPUT
    <?xml version="1.0" encoding="UTF-8"?>
       <gb-standard xmlns="https://www.metanorma.org/ns/gb"  type="semantic" version="#{Metanorma::Gb::VERSION}">
       <bibdata type="standard">
         <docidentifier type="gb">GB/Z 123</docidentifier>
<docnumber>123</docnumber>
         <contributor>
           <role type="author"/>
           <person>
             <name>
               <surname>Author</surname>
             </name>
           </person>
         </contributor>
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
             <name>General Administration of Quality Supervision, Inspection and Quarantine; Standardization Administration of China</name>
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
               <name>General Administration of Quality Supervision, Inspection and Quarantine; Standardization Administration of China</name>
             </organization>
           </owner>
         </copyright>
         <ext>
         <doctype>guide</doctype>
<structuredidentifier>
  <project-number>GB/Z 123</project-number>
</structuredidentifier>
<stagename>International standard</stagename>
         <gbtype>
           <gbscope>national</gbscope>
           <gbprefix>GB</gbprefix>
           <gbmandate>guide</gbmandate>
           <gbtopic>basic</gbtopic>
         </gbtype>
         </ext>
       </bibdata>
       <boilerplate> </boilerplate>
       <sections/>
       </gb-standard>
    OUTPUT
  end

  it "processes metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :scope: local
      :prefix: DB81/T
      :docnumber: 123
      :nodoc:
      :novalid:
      :language: en
      :script: Latn

    INPUT
    <?xml version="1.0" encoding="UTF-8"?>
       <gb-standard xmlns="https://www.metanorma.org/ns/gb"  type="semantic" version="#{Metanorma::Gb::VERSION}">
       <bibdata type="standard">
         <docidentifier type="gb">DB81/123</docidentifier>
<docnumber>123</docnumber>
         <contributor>
           <role type="author"/>
           <person>
             <name>
               <surname>Author</surname>
             </name>
           </person>
         </contributor>
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
             <name>Hong Kong Special Administrative Region</name>
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
               <name>Hong Kong Special Administrative Region</name>
             </organization>
           </owner>
         </copyright>
         <ext>
         <doctype>standard</doctype>
<structuredidentifier>
  <project-number>DB81/123</project-number>
</structuredidentifier>
<stagename>International standard</stagename>
         <gbtype>
           <gbscope>local</gbscope>
           <gbprefix>81</gbprefix>
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

  it "processes metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :scope: local
      :prefix: GB/Z
      :docnumber: 123
      :nodoc:
      :novalid:

    INPUT
          <?xml version="1.0" encoding="UTF-8"?>
       <gb-standard xmlns="https://www.metanorma.org/ns/gb"  type="semantic" version="#{Metanorma::Gb::VERSION}">
       <bibdata type="standard">
         <docidentifier type="gb">DBGB/123</docidentifier>
<docnumber>123</docnumber>
         <contributor>
           <role type="author"/>
           <person>
             <name>
               <surname>Author</surname>
             </name>
           </person>
         </contributor>
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
             <name>GB</name>
           </organization>
         </contributor>
         <language>zh</language>
         <script>Hans</script>
         <status>
           <stage abbreviation="IS">60</stage>
           <substage>60</substage>
         </status>
         <copyright>
           <from>#{Date.today.year}</from>
           <owner>
             <organization>
               <name>GB</name>
             </organization>
           </owner>
         </copyright>
         <ext>
         <doctype>standard</doctype>
<structuredidentifier>
  <project-number>DBGB/123</project-number>
</structuredidentifier>
<stagename>国家标准</stagename>
         <gbtype>
           <gbscope>local</gbscope>
           <gbprefix>GB</gbprefix>
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

  it "processes metadata" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :gb, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :scope: local
      :prefix: GB
      :docnumber: 123
      :nodoc:
      :novalid:
      :status: 30
      :language: en

    INPUT
    <?xml version="1.0" encoding="UTF-8"?>
       <gb-standard xmlns="https://www.metanorma.org/ns/gb"  type="semantic" version="#{Metanorma::Gb::VERSION}">
       <bibdata type="standard">
         <docidentifier type="gb">DBGB/123</docidentifier>
<docnumber>123</docnumber>
         <contributor>
           <role type="author"/>
           <person>
             <name>
               <surname>Author</surname>
             </name>
           </person>
         </contributor>
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
             <name>GB</name>
           </organization>
         </contributor>
         <language>en</language>
         <script>Latn</script>
         <status>
           <stage abbreviation="CD">30</stage>
           <substage>00</substage>
         </status>
         <copyright>
           <from>#{Date.today.year}</from>
           <owner>
             <organization>
               <name>GB</name>
             </organization>
           </owner>
         </copyright>
         <ext>
         <doctype>standard</doctype>
<structuredidentifier>
  <project-number>DBGB/123</project-number>
</structuredidentifier>
 <stagename>Committee draft</stagename>
         <gbtype>
           <gbscope>local</gbscope>
           <gbprefix>GB</gbprefix>
           <gbmandate>mandatory</gbmandate>
           <gbtopic>basic</gbtopic>
         </gbtype>
         </ext>
       </bibdata>
       <boilerplate>
  <legal-statement>
    <clause>
      <p id='_'>
        When submitting feedback, please attach any relevant patents that you
        are aware of, together with supporting documents.
      </p>
    </clause>
  </legal-statement>
</boilerplate>
       <sections/>
       </gb-standard>
    OUTPUT
  end

end
