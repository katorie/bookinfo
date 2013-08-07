# encoding: utf-8

require 'rubygems'
require 'dbi'
require 'date'

class BookInfo
  def initialize( title, author, page, publish_date )
    @title = title
    @author = author
    @page = page
    @publish_date = publish_date
  end

  attr_accessor :title, :author, :page, :publish_date

  def to_s
    "#{@title},#{@author},#{@page},#{@publish_date}"
  end

  def toFormattedString( sep = "\n" )
    "書籍名： #{@title}#{sep}著者名： #{@author}#{sep}ページ数： #{@page}#{sep}発刊日： #{@publish_date}#{sep}"
  end
end

class BookInfoManager
  def initialize( sqlite_name )
    @db_name = sqlite_name
    @dbh = DBI.connect( "DBI:SQLite3:#{@db_name}" )

    @item_name = {'id' => "キー", 'title' => "書籍名", 'author' => "著者名", 'page' => "ページ数", 'publish_date' => "発刊日" }
  end

  def initBookInfos
    puts "\n０．蔵書データベースの初期化"
    print "初期化しますか？（Y/yなら削除を実行します）"
    yesno = gets.chomp.upcase
    if /^Y$/ =~ yesno
      @dbh.do("drop table if exists bookinfos")
      @dbh.do("create table bookinfos (
        id              varchar(50)   not null,
        title           varchar(100)  not null,
        author          varchar(100)  not null,
        page            int           not null,
        publish_date    datetime      not null,
        primary         key(id));")
      puts "\nデータベースを初期化しました"
    end
  end  

  def addBookInfo
    puts "\n１．蔵書データの登録"
    print "蔵書データを登録します"

    book_info = BookInfo.new( "", "", 0, Date.new )
    print "\n" 
    print "キー："
    key = gets.chomp
    print "書籍名："
    book_info.title = gets.chomp
    print "著者名:"
    book_info.author = gets.chomp
    print "ページ数："
    book_info.page = gets.chomp.to_i
    print "発刊年："
    year = gets.chomp.to_i
    print "発刊月："
    month = gets.chomp.to_i
    print "発刊日："
    day = gets.chomp.to_i
    book_info.publish_date = Date.new( year, month, day )

    @dbh.do("insert into bookinfos values (
      '#{key}',
      '#{book_info.title}',
      '#{book_info.author}',
      '#{book_info.page}',
      '#{book_info.publish_date}');")
    puts "\n登録しました"
  end

  def listAllBookInfos
    puts "\n２．蔵書データの表示"
    print "蔵書データを表示します"
    
    puts "\n--------------------"

    sth = @dbh.execute("select * from bookinfos")

    counts = 0
    sth.each do |row|
      row.each_with_name do |val, name|
        print "#{@item_name[name]}:"
        print "#{val.to_s}\n"
        end
      puts "--------------------"
      counts = counts + 1
    end

    sth.finish

    puts "\n#{counts}件表示しました"
  end

  def run
    while true
      print"
０．蔵書データベースの初期化
１．蔵書データの登録
２．蔵書データの表示
９．終了
番号を選んでください(0,1,2,9)："
      num = gets.chomp
      case
      when '0' == num
        initBookInfos
      when '1' == num
        addBookInfo
      when '2' == num
        listAllBookInfos
      when '9' == num
        @dbh.disconnect
        puts "\n終了しました"
        break;
      else
      end
    end
  end

end

book_info_manager = BookInfoManager.new("bookinfo_sqlite.db")

book_info_manager.run
