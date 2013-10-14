$ ->

    types = [
        {value: "Restaurants", tokens: ["Food", "Restaurants"]},
        {value: "Hotels", tokens: ["Hotel", "Lodging","bed","sleep"]},
        {value: "Motels", tokens: ["motel", "lodging","bed","sleep"]},
        {value: "Lodging", tokens: ["lodging","sleep","bed"]},
    ]
    Underscore = 
        compile: (template) ->
            compiled = _.template(template)
            render: (context) -> 
                compiled(context)

    $(".js-search").typeahead
        local: types
        limit: 10000
        engine: Underscore
        template: $("#typeahead-item")

    # $(".js-set-distance").typeahead
    #     local: types
    #     limit: 10000
    #     engine: Underscore
    #     template: $("#typeahead-item")