require 'httparty'

class Post
  include HTTParty

  def initialize
    @api_url = "https://dash.sharpetronics.com/api"
  end

  def all
    self.class.get("#{@api_url}/posts?populate=*")
    
  end

end

post = Post.new
pp post.all
