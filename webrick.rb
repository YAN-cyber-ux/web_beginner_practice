# webrick.rb
require 'webrick'
require 'erb'
require 'debug'

server = WEBrick::HTTPServer.new({ 
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 8000
})

server.mount_proc("/time") do |req, res|
  # レスポンス内容を出力
  body = "<html><body>#{ Time.new }</body></html>"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

server.mount_proc("/form_get") do |req, res|
  body = "<html><head><meta charset=\"utf-8\"/></head><body>"
  body += "<p>こんにちは、#{ req.query }</p>"
  body += "<p>あなたの名前は#{ req.query['username'] }ですね。</p>"
  body += "<p>あなたの年齢は#{ req.query['age'] }ですね。</p>"
  body += "</body></html>"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

server.mount_proc("/form_post") do |req, res|
  req.query
  body = "<html><head><meta charset=\"utf-8\"/></head><body>"
  body += "<p>こんにちは、#{ req.query }</p>"
  body += "<p>あなたの名前は#{ req.query['username'] }ですね。</p>"
  body += "<p>あなたの年齢は#{ req.query['age'] }ですね。</p>"
  body += "</body></html>"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

foods = [
  { id: 1, name: "りんご", category: "fruits" },
  { id: 2, name: "バナナ", category: "fruits" },
  { id: 3, name: "いちご", category: "fruits" },
  { id: 4, name: "トマト", category: "vegetables" },
  { id: 5, name: "キャベツ", category: "vegetables" },
  { id: 6, name: "レタス", category: "vegetables" },
]

server.mount_proc("/foods") do |req, res|
  template = ERB.new( File.read('./foods/index.erb') )
  @selected_category = req.query["category"]
  @foods =  if @selected_category == nil
              foods
            elsif @selected_category == "all"
              foods
            else
              foods.select { |food| food[:category] == @selected_category }
            end
  res.body << template.result( binding )
end

WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
server.config[:MimeTypes]["erb"] = "text/html"

server.mount_proc("/hello") do |req, res|
  template = ERB.new( File.read('hello.erb') )
  @now = Time.now
  res.body << template.result( binding )
end



trap(:INT){
    server.shutdown
}

server.start
