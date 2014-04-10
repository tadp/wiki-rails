class App.Views.LastUpdated extends Backbone.View
  initialize: ->
    @listenTo(@model, 'change:updated_at', @render)

	render: ->
		@$el.html(@lastUpdated())
		this

  lastUpdated: ->
    @model.get("updated_at").calendar()