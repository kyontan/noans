get "/api/get/?:type?" do
	content_type :text, :charset => 'utf-8'

	if params[:type] == "text" then
		#@redis.get("karitext")
		status 418
	else
		"No (or missing) type is specified."
	end
end
