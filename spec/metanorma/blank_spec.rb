require_relative "../spec_helper"

RSpec.describe Metanorma::Gb do
  it "processes a blank document" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
      <sections/>
    OUTPUT
    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
  end

  it "converts a blank document to files" do
    input = <<~INPUT
= Document title
Author
:docfile: test.adoc
:novalid:
:no-isobib:

.前言
本文件按照GB/T 1.1—2020《标准化工作导则  第1部分：标准化文件的结构和起草规则》的规定起草。 

[[introduction]]
== 引言

无。

== 范围

本文件规定了数字电影LED影厅的技术要求及相应的测量方法。

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections/>
    OUTPUT
    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
    # expect(File.exist?("test_compliant.html")).to be true
    # expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.doc")).to be true
    # expect(File.exist?("test.pdf")).to be true
  end
end
