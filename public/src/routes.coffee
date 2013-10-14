$ ->
    WorkSpace = Backbone.Router.extend
        routes: 
            "business/:id": "showBusiness"
        # name is id attribute
        showBusiness: (id) ->
            b = window.businesses._byId[id]
            cc id 
            if b
                window.businesses.selectItem b

    window.app = new WorkSpace
    Backbone.history.start()