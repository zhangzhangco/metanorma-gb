require_relative "../spec_helper"

RSpec.describe Metanorma::Gb do
  it "has a version number" do
    expect(Metanorma::Gb::VERSION).not_to be nil
  end

  it "processes default metadata" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = 数字电影LED影厅技术要求和测量方法
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :mandate: recommended
      :library-ics: 11.060
      :library-ccs: N40
      :library-plan: 备案号
      :scope: national
      :prefix: GB
      :docnumber:
      :obsoletes: GB/T 123—1995
      :title-intro-zh: 数字电影
      :title-main-zh: LED影厅
      :title-part-zh: 技术要求和测量方法
      :title-intro-en: Digital cinema
      :title-main-en: LED screen
      :title-part-en: Technical requirements and test methods
      :adoption-type: nonequivalent
      :adoption-title: ISO/IEC 1234:2001,LED Standard
      :revdate: 2023-05-01
      :docstage: 30
      :published-date:
      :implemented-date:
      :issuer:
      :technical-committee-type: TC
      :technical-committee-number: 586
      :technical-committee: 全国电影标准化技术专业委员会
      :proposer: 提出单位1,提出单位2
      :author: 李娜,董强国,刘知一
      :copyright-year: 2023
    INPUT
    output = <<~OUTPUT
    <?xml version="1.0" encoding="UTF-8"?>
    <gb-standard xmlns="https://www.metanorma.org/ns/gb" type="semantic" version="#{Metanorma::Gb::VERSION}">
      <bibdata type="standard">
        <title language="en" format="plain" type="main">Digital cinema — LED screen — Technical requirements and test methods</title>
        <title language="en" format="plain" type="title-intro">Digital cinema</title>
        <title language="en" format="plain" type="title-main">LED screen</title>
        <title language="en" format="plain" type="title-part">Technical requirements and test methods</title>
        <title language="zh" format="plain" type="main">数字电影 — LED影厅 — 技术要求和测量方法</title>
        <title language="zh" format="plain" type="title-intro">数字电影</title>
        <title language="zh" format="plain" type="title-main">LED影厅</title>
        <title language="zh" format="plain" type="title-part">技术要求和测量方法</title>
        <date type="published">
          <on/>
        </date>
        <date type="implemented">
          <on/>
        </date>
        <contributor>
          <role type="author"/>
          <person>
            <name>李娜</name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name>董强国</name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name>刘知一</name>
          </person>
        </contributor>
        <contributor>
          <role type="proposer"/>
          <organization>
            <name>提出单位1</name>
          </organization>
        </contributor>
        <contributor>
          <role type="proposer"/>
          <organization>
            <name>提出单位2</name>
          </organization>
        </contributor>
        <version>
          <revision-date>2023-05-01</revision-date>
        </version>
        <language>zh</language>
        <script>Hans</script>
        <status>
          <stage abbreviation="CD">30</stage>
          <substage>00</substage>
        </status>
        <copyright>
          <from>2023</from>
          <owner>
            <organization>
              <name>GB</name>
            </organization>
          </owner>
        </copyright>
        <relation type="adoptedFrom">
          <description>nonequivalent</description>
          <bibitem>
            <title>LED Standard</title>
            <docidentifier>ISO/IEC 1234:2001</docidentifier>
          </bibitem>
        </relation>
        <relation type="obsoletes">
          <bibitem>
            <title>[not supplied]</title>
            <docidentifier>GB/T 123—1995</docidentifier>
          </bibitem>
        </relation>
        <ext>
          <doctype>standard</doctype>
          <gbcommittee type="TC" number="586">全国电影标准化技术专业委员会</gbcommittee>
          <ics>
            <code>11.060</code>
            <text>Dentistry</text>
          </ics>
          <ccs>N40</ccs>
          <plannumber>备案号</plannumber>
          <structuredidentifier>
            <project-number/>
          </structuredidentifier>
          <stagename>标准草案征求意见稿</stagename>
          <gbtype>
            <gbscope>national</gbscope>
            <gbprefix>GB</gbprefix>
            <gbmandate>recommended</gbmandate>
            <gbtopic>basic</gbtopic>
          </gbtype>
        </ext>
      </bibdata>
      <sections/>
    </gb-standard>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(xmlpp(strip_guid(xml.to_xml)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes national standard GB/Z (Standardized guiding technical document) metadata" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = 数字电影LED影厅技术要求和测量方法
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docstage: 20
      :docsubstage: 20
      :mandate: recommended
      :library-ics: 11.060
      :library-ccs: N40
      :library-plan: 备案号
      :scope: national
      :prefix: GB/Z
      :docnumber: 8888
    INPUT
    output = <<~OUTPUT
    <?xml version="1.0" encoding="UTF-8"?>
       <gb-standard xmlns="https://www.metanorma.org/ns/gb" type="semantic" version="#{Metanorma::Gb::VERSION}">
         <bibdata type="standard">
           <docidentifier type="gb">8888</docidentifier>
           <docnumber>8888</docnumber>
           <language>zh</language>
           <script>Hans</script>
           <status>
             <stage abbreviation="WD">20</stage>
             <substage>20</substage>
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
             <doctype>technical-document</doctype>
             <ics>
               <code>11.060</code>
               <text>Dentistry</text>
             </ics>
             <ccs>N40</ccs>
             <plannumber>备案号</plannumber>
             <structuredidentifier>
               <project-number> 8888</project-number>
             </structuredidentifier>
             <stagename>标准草案工作组讨论稿</stagename>
             <gbtype>
               <gbscope>national</gbscope>
               <gbprefix>GB</gbprefix>
               <gbmandate>recommended</gbmandate>
               <gbtopic>basic</gbtopic>
             </gbtype>
           </ext>
         </bibdata>
         <sections/>
       </gb-standard>
    OUTPUT
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(xmlpp(strip_guid(xml.to_xml)))
      .to be_equivalent_to xmlpp(output)
  end
end

