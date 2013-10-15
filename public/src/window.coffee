window.WorkSpace = Backbone.Router.extend
    routes: 
        "business/:id": "showBusiness"
        "business/:id/full": "fullBusiness"
    fullBusiness: (id) ->
        b = window.businesses._byId[id]
        # if so, select it in the list
        if b
            launchModal new window.GMapBusiness({model: b}).render().el, { destroyHash: true }
    # name is id attribute
    showBusiness: (id) ->
        # check to see if the business is in the list
        b = window.businesses._byId[id]
        # if so, select it in the list
        if b
            window.businesses.list.selectItem b

$ ->
    window.launchModal =  (content, options) ->
        destroyModal true
        defaults = 
            close: true
            destroyHash: false
        options = _.extend defaults, options
        modal = $("<div />").addClass("modal")
        if $.isArray(content)
          _.each content, (item) ->
              modal.append(item)
        else modal.html(content)
        unless options.close is false
            modal.prepend("<i class='close-modal icon-cancel'></i>")
            modal.find(".close-modal").on "click", ->
                $(document.body).removeClass("active-modal")
                modal.remove()
                if options.destroyHash is true
                    window.location.hash = ""
        $(document.body).addClass("active-modal").append(modal)
        modal
    window.destroyModal = (existing) ->
        $(".modal").fadeOut "fast", ->
            unless existing == true
                $(document.body).removeClass("active-modal")
