require "vcr"

OPTIONS = [backend: :gb, header_footer: true].freeze

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.default_cassette_options = {
    clean_outdated_http_interactions: true,
    re_record_interval: 1512000,
    record: :once,
  }
end

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "nokogiri"
require "asciidoctor"
# require "metanorma-iso"
# require "metanorma/iso"
require "rspec/matchers"
require "equivalent-xml"
# require "metanorma"
# require "rexml/document"

libx = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)
require "metanorma/gb"
Dir.glob(File.join(File.dirname(__FILE__), %w(.. lib *.rb ))).each do |file|
  require file
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def metadata(x)
  Hash[x.sort].delete_if{ |k, v| v.nil? || v.respond_to?(:empty?) && v.empty? }
end

def strip_guid(x)
  x.gsub(%r{ id="_[^"]+"}, ' id="_"').gsub(%r{ target="_[^"]+"}, ' target="_"')
end

def htmlencode(x)
  HTMLEntities.new.encode(x, :hexadecimal).gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n").
    gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, '&').gsub(/&#x27;/, "'").
    gsub(/\\u(....)/) { |s| "&#x#{$1.downcase};" }.gsub(/, :/, ",\n:")
end

def xmlpp(xml)
  c = HTMLEntities.new
  xml &&= xml.split(/(&\S+?;)/).map do |n|
    if /^&\S+?;$/.match?(n)
      c.encode(c.decode(n), :hexadecimal)
    else n
    end
  end.join
  xsl = <<~XSL
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
      <xsl:strip-space elements="*"/>
      <xsl:template match="/">
        <xsl:copy-of select="."/>
      </xsl:template>
    </xsl:stylesheet>
  XSL
  ret = Nokogiri::XSLT(xsl).transform(Nokogiri::XML(xml, &:noblanks))
    .to_xml(indent: 2, encoding: "UTF-8")
    .gsub(%r{<fetched>20[0-9-]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
  r = HTMLEntities.new.decode(ret)
end

ASCIIDOC_BLANK_HDR = <<~"HDR".freeze
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:

HDR

ISOBIB_BLANK_HDR = <<~"HDR".freeze
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib-cache:
      :language: en
      :script: Latn

HDR

ISOBIB_BLANK_HDR_ZH = <<~"HDR".freeze
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib-cache:
      :language: zh
      :script: Hans

HDR

VALIDATING_BLANK_HDR = <<~"HDR".freeze
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:

HDR

BOILERPLATE = <<~"END".freeze
<boilerplate/>
END

BLANK_HDR1 = <<~"HDR".freeze
<?xml version="1.0" encoding="UTF-8"?>
<gb-standard xmlns="https://www.metanorma.org/ns/gb" type="semantic" version="#{Metanorma::Gb::VERSION}">
  <bibdata type="standard">
    <contributor>
      <role type="author"/>
      <person>
        <name>Author</name>
      </person>
    </contributor>
    <language>zh</language>
    <script>Hans</script>
    <status>
      <stage>60</stage>
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
        <project-number/>
      </structuredidentifier>
      <stagename>现行标准</stagename>
      <gbtype>
        <gbscope>national</gbscope>
        <gbprefix>GB</gbprefix>
        <gbmandate>mandatory</gbmandate>
        <gbtopic>basic</gbtopic>
      </gbtype>
    </ext>
  </bibdata>
  <metanorma-extension>
    <presentation-metadata>
      <name>TOC Heading Levels</name>
      <value>3</value>
    </presentation-metadata>
    <presentation-metadata>
      <name>HTML TOC Heading Levels</name>
      <value>2</value>
    </presentation-metadata>
    <presentation-metadata>
      <name>DOC TOC Heading Levels</name>
      <value>3</value>
    </presentation-metadata>
  </metanorma-extension>
HDR

BLANK_HDR = <<~"HDR".freeze
  #{BLANK_HDR1}
  #{BOILERPLATE}
HDR

HTML_HDR = <<~HDR.freeze
         <body lang="en">
           <div class="title-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="main-section">
HDR

HTML_HDR_ZH = <<~HDR.freeze
         <body lang="zh">
           <div class="title-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="main-section">
HDR

GBT20223 = <<~OUTPUT.freeze
<bibitem type="standard" id="GB/T20223">
  <fetched>#{Date.today}</fetched>
  <title format="text/plain" language="zh" script="Hans">棉短绒</title>
  <title format="text/plain" language="en" script="Latn">Cotton linter</title>
  <uri type="src">http://www.std.gov.cn/gb/search/gbDetailed?id=5DDA8BA00FC618DEE05397BE0A0A95A7</uri>
  <docidentifier type="GB">GB/T 20223</docidentifier>
  <date type="published">
    <on>2006</on>
  </date>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>GB/T</name>
      <abbreviation>GB/T</abbreviation>
    </organization>
  </contributor>
  <language>zh</language>
  <script>Hans</script>
  <status><stage>obsoleted</stage></status>
</bibitem>
      OUTPUT
