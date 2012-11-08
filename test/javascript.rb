module Javascript
  include Haml::Filters::Base
	 
  def render(str)
  	"<script>#{Haml::Helpers.html_escape(str.strip)}</script>"
  end
  
end