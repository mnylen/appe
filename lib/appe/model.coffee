
class FieldSelector
	constructor: (selectors) ->
		if not (selectors instanceof Array)
			@selectors = [selectors]
		else
			@selectors = selectors

		@selectors = (selector.split(".") for selector in @selectors)

	selectFields: (event) ->
		fields = {}

		for selector in @selectors
			parent = event.fields
			name   = ""
			added = false

			for fieldSelector in selector
				break if added
				if fieldSelector == "*"
					added = true
					# Select all fields from current parent
					for own field, value of parent
						if typeof value != 'object'
							fieldName = if name != "" then name + "." + field else field
							fields[fieldName] = value
				else
					parent = parent[fieldSelector]
					name  += if name != "" then "." + fieldSelector else fieldSelector

					if parent == undefined or parent == null
						fields[name] = null
						added = true

			fields[name] = parent if not added

		fields

class Event
	constructor: (@type, @fields) ->

module.exports =
	Event 		  : Event
	FieldSelector : FieldSelector