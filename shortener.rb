require 'sinatra'
require "sinatra/reloader" if development?
require 'active_record'
require 'pry'
require 'zlib'

configure :development, :production do
    ActiveRecord::Base.establish_connection(
       :adapter => 'sqlite3',
       :database =>  'db/dev.sqlite3.db',
       :pool => 20
     )
end

# Quick and dirty form for testing application
#
# If building a real application you should probably
# use views: 
# http://www.sinatrarb.com/intro#Views%20/%20Templates
form = <<-eos
    <form id='myForm'>
        <input type='text' name="url">
        <input type="submit" value="Shorten"> 
    </form>
    <h2>Results:</h2>
    <h3 id="display"></h3>
    <script src="jquery.js"></script>

    <script type="text/javascript">
        $(function() {
            $('#myForm').submit(function() {
            $.post('/new', $("#myForm").serialize(), function(data){
                $('#display').html(data);
                });
            return false;
            });
    });
    </script>
eos

# Models to Access the database 
# through ActiveRecord.  Define 
# associations here if need be
#
# http://guides.rubyonrails.org/association_basics.html
class Link < ActiveRecord::Base
end

get '/' do
    form
end

post '/new' do
    long = params[:url]
    short = Zlib::crc32(long).to_i.to_s(16)
    link = Link.find_by_short(short)
    unless link
      link = Link.new
      link.long = long
      link.short = short
      link.save
    end
    "<a href='#{link.short}''>localhost:4567/#{link.short}</a>"
end

get '/jquery.js' do
    send_file 'jquery.js'
end

get '/*' do
    input = request.path_info
    input.slice!(0)
    shao = Link.find_by_short(input)

    if shao
        redirect "http://#{shao.long}"
    else
        "404 not found."
    end
end

####################################################
####  Implement Routes to make the specs pass ######
####################################################
