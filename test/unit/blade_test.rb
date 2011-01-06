# coding: utf-8
require 'test_helper'
require 'blade.rb'
require 'fakeweb'

{
  "42900.html" =>
    "http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-dev/42900",
  "index.shtml" =>
    "http://blade.nagaokaut.ac.jp/ruby/ruby-dev/index.shtml",
  "42801-43000.html" =>
    "http://blade.nagaokaut.ac.jp/ruby/ruby-dev/42801-43000.shtml#latest",
}.each do |file, url|
  FakeWeb.register_uri(:get, url, :body => File.read("test/data/#{file}"))
end

class BladeTest < ActiveSupport::TestCase
  test "Blade.new creates an instance" do
    assert_instance_of Blade, Blade.new(42900)
  end

  test "Blade#get downloads the html" do
    html = Blade.new(42900).get
    assert_equal html.encoding, Encoding.find("utf-8")
    assert_match html, /チケット/
  end

  test "Blade#parse returns a hash" do
    data = Blade.new(42900).parse

    assert_equal data[:number], 42900
    assert_equal data[:subject], "[Ruby 1.9-Bug#4152][Closed] optparseのzsh compsysでrspecの補完が出来ない"
    assert_equal data[:from], "<strong>Anonymous </strong>&lt;redmine ruby-lang.org&gt;"
    assert_equal data[:time], ActiveSupport::TimeZone["Tokyo"].local(2010, 12, 27, 8, 37, 11)
    assert_equal data[:in_reply_to], nil
    assert_equal data[:body], "チケット #4152 が更新されました。 (by Anonymous)\n\nステータス AssignedからClosedに変更\n進捗 % 0から100に変更\n\nThis issue was solved with changeset r30394.\nKazuhiro, thank you for reporting this issue.\nYour contribution to Ruby is greatly appreciated.\nMay Ruby be with you.\n\n----------------------------------------\n<a href=\"http://redmine.ruby-lang.org/issues/show/4152\" target=\"_top\">http://redmine.ruby-lang.org/issues/show/4152</a>\n\n----------------------------------------\n<a href=\"http://redmine.ruby-lang.org\" target=\"_top\">http://redmine.ruby-lang.org</a>\n\n<a name=\"tail\"></a>"
  end

  test "Blade#create creates a Mail" do
    mail = nil
    assert_difference "Mail.count", 1 do
      mail = Blade.new(42900).create
    end
    assert_instance_of Mail, mail
  end
end
