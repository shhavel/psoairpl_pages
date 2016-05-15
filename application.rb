# encoding: UTF-8
require 'sinatra'
require 'tilt/erubis'
require 'rdiscount'
require 'htmlcompressor'
require 'wicked_pdf'
set :root, File.dirname(__FILE__)
configure { mime_type :pdf, 'application/pdf' }

get '/:folder/index.html' do
  @lang = params[:folder].sub('-ruby', '')
  @title = @page_title = title(params[:folder])
  @menu = menu(params[:folder])
  @description = index_description(params[:folder])
  @keywords = index_keywords(params[:folder])
  @text = @files.inject("<h1>#{@title}</h1>") do |text, file|
    url = file.sub(/views/, '').sub(/\.md$/, '.html')
    ch = File.read(file)
    title = ch.split("\n").first
    anchors = ch.scan(/## <a name="([^"<>]+)"><\/a>\s*(.+)\s*/)

    text << "<h2><a href=\"#{url}\">#{title}</a></h2><ul>"
    anchors.each {|(a, name)| text << "<li><a href=\"#{url}##{a}\">#{name.gsub('`', '')}</a></li>" }
    text << "</ul>"
  end
  erb(:page).tap { |p| File.open("public/#{params[:folder]}/index.html", 'w') { |f| f.write(HtmlCompressor::Compressor.new.compress(p).gsub(/>\s+</, '><')) } }
end

get '/:folder/:page.html' do
  @lang = params[:folder].sub('-ruby', '')
  @title = title(params[:folder])
  ch = File.read("views/#{params[:folder]}/#{params[:page]}.md")
  @page_title = ch.split("\n").first.sub(/.+\.\s+/, '')
  @menu = menu(params[:folder])
  @text = markdown(:"#{params[:folder]}/#{params[:page]}")
  @text.gsub!('<pre><code class="ruby">', '<pre class="prettyprint lang-ruby">')
  @text.gsub!('<pre><code class="yaml">', '<pre class="prettyprint lang-yaml">')
  @text.gsub!('<pre><code>', '<pre class="prettyprint">')
  @text.gsub!('</code></pre>', '</pre>')
  @description = index_description(params[:folder])
  @keywords = ch.scan(/(?<=\[)([^\]]+)(?=\]\()/).map(&:first).uniq | ['ruby', 'sinatra', 'SOA', 'API', 'HTTP API', 'rails-api']
  erb(:page).tap { |p| File.open("public/#{params[:folder]}/#{params[:page]}.html", 'w') { |f| f.write(HtmlCompressor::Compressor.new.compress(p).gsub(/>\s+</, '><')) } }
end

get '/service_oriented_arhitecture_in_practice_:lang.pdf' do
  @title = title(params[:lang])
  @author = author(params[:lang])
  contents = (params[:lang] == 'uk' ? "Зміст" : (params[:lang] == 'ru' ? "Содержание" : "Contents"))

  @chapters = []
  @files = Dir["views/#{params[:lang]}-ruby/*.md"].sort_by {|f| f =~ /\/preface.md$/ ? '0' : f }

  @index = @files.each_with_index.inject("<h1>#{contents}</h1>") do |text, (file, ind)|
    chapter_anch = (ind == 0 ? 'preface' : (ind == 10 ? "chapter10" : "chapter0#{ind}"))
    ch = File.read(file)
    @chapters << markdown(file.sub(/views/, '').sub(/\.md$/, '').to_sym).gsub('<a name="', "<a name=\"#{chapter_anch}-").gsub('../static/images', '/Users/alex/scripts/soabp-online/public/static/images')
    title = ch.split("\n").first
    anchors = ch.scan(/## <a name="([^"<>]+)"><\/a>\s*(.+)\s*/)

    text << "<h2><a href=\"##{chapter_anch}\">#{title}</a></h2><ul>"
    anchors.each {|(a, name)| text << "<li><a href=\"##{chapter_anch}-#{a}\">#{name.gsub('`', '')}</a></li>" }
    text << "</ul>"
  end
  @index = HtmlCompressor::Compressor.new.compress(@index).gsub(/>\s+</, '><')
  @chapters = @chapters.map {|ch| HtmlCompressor::Compressor.new.compress(ch).gsub(/>\s+</, '><') }

  html_pdf = erb(:page_pdf)
  footer_pdf = erb(:footer_pdf).gsub("\n", '')

  file_path = File.join(settings.root, 'public', 'static', "service_oriented_arhitecture_in_practice_#{params[:lang]}.pdf").to_s
  File.open(file_path, 'wb') do |file|
    file << ::WickedPdf.new.pdf_from_string(html_pdf,
      footer: { content: footer_pdf }, page_size: 'a4', orientation: 'Portrait',
      disable_internal_links: false, disable_external_links: false,
      margin: { top: 20, bottom: 20, left: 25, right: 25 })
  end
  send_file file_path, type: :pdf
end


# helpers
def menu(folder)
  content = folder == 'uk-ruby' ? "Зміст" : (folder == 'ru-ruby' ? "Содержание" : "Contents")
  @files ||= Dir["views/#{folder}/*.md"].sort_by {|f| f =~ /\/preface.md$/ ? '0' : f }
  @menu ||=  @files.map do |file|
    url = file.sub(/views/, '').sub(/\.md$/, '.html')
    ch = File.read(file)
    title = ch.split("\n").first
    [url, title]
  end.tap {|m| m.unshift(["/#{folder}/index.html", content]) }
end

def title(folder)
  if folder == 'uk-ruby' || folder == 'uk'
    "Сервіс-орієнтована архітектура на практиці"
  elsif folder == 'ru-ruby' || folder == 'ru'
    "Сервис-ориентированная архитектура на практике"
  else
    "Service Oriented Architecture in Practice"
  end
end

def index_description(folder)
  if folder == 'uk-ruby'
    "Побудова REST веб-сервісу на ruby використовуючи sinatra: фільтрування параметрів, авторизація, пошук, створення документації на основі тестів, оптимізація, дистанційна аутентифікація у веб-сервісах."
  elsif folder == 'ru-ruby'
    "Построение REST веб-сервиса на ruby используя sinatra: фильтрование параметров, авторизация, поиск, создание документации на основе тестов, оптимизация, удалённая аутентификация в веб-сервисах."
  else
    "Building a REST web service using ruby and sinatra: filtering parameters, authorization, search, create documentation on the basis of tests, optimization, remote authentication in web services."
  end
end

def index_keywords(folder)
  if folder == 'uk-ruby'
    ["REST", "веб-сервіс", 'ruby', "sinatra", 'activerecord', 'rspec_api_documentation', 'sinatra-param', 'sinatra-can', 'ransack', 'activeresource', 'SOA', 'API', 'HTTP API', 'rails-api']
  elsif folder == 'ru-ruby'
    ["REST", "веб-сервис", 'ruby', "sinatra", 'activerecord', 'rspec_api_documentation', 'sinatra-param', 'sinatra-can', 'ransack', 'activeresource', 'SOA', 'API', 'HTTP API', 'rails-api']
  else
    ["REST", "web service", 'ruby', "sinatra", 'activerecord', 'rspec_api_documentation', 'sinatra-param', 'sinatra-can', 'ransack', 'activeresource', 'SOA', 'API', 'HTTP API', 'rails-api']
  end
end

def author(lang)
  if lang == 'uk'
    "Олександр Авоянц"
  elsif lang == 'ru'
    "Александр Авоянц"
  else
    "by Oleksandr Avoiants"
  end
end
