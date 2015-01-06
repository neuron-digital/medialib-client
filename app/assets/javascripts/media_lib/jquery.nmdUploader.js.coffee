#= require jquery
#= require underscore
#= require media_lib/jquery.md5
#= require media_lib/inserter_factory

$(window).on "message", (e) ->
  data = e.originalEvent.data
  if data?
    switch data.type
      when 'select'
        $uploader = $("##{data.model.uploaderId}")
        uploader = $uploader.data()
        
        $uploader.nmdUploader 'select',
          model: data.model
          uploader: uploader

        # Закрытие модального окна при интеграции с модалками
        $('div[id^="nmdUploaderModal"]').modal('hide') if $.fn.modal? and not uploader.multiselect

$ ->
  methods =
    init: (options) ->
      settings = _.extend
        host: null
        tenant: null
        open: false
        multiselect: false
      , options

      throw "host isn't defined" unless settings.host?
      throw "tenant isn't defined" unless settings.tenant?

      @each ->
        $uploader = $(@)
        uploader = $uploader.data()

        multiselect = settings.multiselect or uploader.multiselect

        uploaderId = $.md5(Math.random())[0..3]
        if $uploader.attr 'id' then uploaderId = $uploader.attr 'id'
        else $uploader.attr 'id', uploaderId

        getUrl = ->
          # "Живой" префикс
          prefix = $uploader.data('prefix')
          throw "prefix isn't defined" unless prefix?

          url = "
            #{settings.host}/#
            v2/
            #{settings.tenant}/
            #{if multiselect then 'multiselect/' else ''}
            #{uploaderId}/
            #{prefix}
          ".replace /\ /g, ''

        openUploader = ->
          $uploaderIframes = $uploader.find('iframe.js-uploader-iframe')
          $uploaderIframes.add $("##{settings.open}").find('iframe.js-uploader-iframe') if settings.open
          if $uploaderIframes.length
            iframeTemplate = _.template '''
              <iframe width='<%= width %>' height='<%= height %>' src='<%= src %>' frameborder='0'></iframe>
            '''

            $uploader.find('.js-uploader-open').on 'click', ->
              $uploaderIframes.each ->
                $iframe = $ @
                iframeData = $iframe.data()
                $iframe.html iframeTemplate
                  src: getUrl()
                  width: iframeData.width or '100%'
                  height: iframeData.height or 500

            # Для TinyMCE id модального окна передаётся в параметре
            $("##{settings.open}").modal('show') if settings.open and $.fn.modal?
          else
            popupWindow = open getUrl(), 'NMD Media Lib', 'scrollbars=1, width=800, height=500'
            popupWindow.focus()

        if settings.open
          openUploader() 
        else
          $uploader.find('.js-uploader-open').on 'click', (e) ->
            e.preventDefault()
            e.stopPropagation()
            openUploader()

    select: (options) ->
      settings = _.extend {}, options
      factory = new MediaLib.InserterFactory settings.uploader, settings.model
      inserter = factory.createInserter()
      @each -> inserter.insert $(@) if inserter?

  $.fn.nmdUploader = (method) ->
    if methods[method] then methods[method].apply @, Array::slice.call(arguments, 1)
    else if typeof method is "object" or not method then methods.init.apply @, arguments
    else throw "Метод с именем #{method} не существует для jQuery.nmdUploader"