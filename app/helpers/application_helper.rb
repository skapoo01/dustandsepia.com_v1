module ApplicationHelper
	def sortable(column, title = nil)
    		title ||= column.titleize
    		css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    		direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    		icon = sort_direction == "asc" ? "white arrow circle down icon" : "white arrow circle up icon"
    		icon = column == sort_column ? icon : ""
    		link_to "#{title} <i class='#{icon}'></i>".html_safe, params.merge(:sort => column, :direction => direction), {:class => css_class}
  	end

  	def filterable(field, type, title = nil)
  		if field == "All"
  			key = nil
  			value = nil
  			title = field
  		elsif type == 'section'
  			key = "section_id"
  			value = field.id
  			title ||= field.title.titleize
  		elsif type == 'author'
  			key = "author"
  			value = field.id
  			title ||= field.name.titleize
  		elsif type == 'series'
  			key = "series_id"
  			value = field.id
  			title ||= field.title.titleize
  		end

  		if field == "Clear Filters"
  			link_to "Clear Filters", {:filter_by => nil, :value => nil}
  		else
  			link_to "#{title}", params.merge(:filter_by => key, :value => value)
  		end
  	end
end
