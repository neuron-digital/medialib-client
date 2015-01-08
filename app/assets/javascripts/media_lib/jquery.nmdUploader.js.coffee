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
      settings = $.extend true,
        {}
      , options

      throw "host isn't defined" unless settings.host
      throw "tenant isn't defined" unless settings.tenant

      @each ->
        $uploader = $ @
        uploader = $uploader.data()

        uploaderId = $.md5(Math.random())[0..3]
        if $uploader.attr 'id' then uploaderId = $uploader.attr 'id'
        else $uploader.attr 'id', uploaderId

        getUrl = ->
          # "Живой" префикс
          prefix = settings.prefix ? $uploader.data('prefix')
          throw "prefix isn't defined" unless prefix

          multiselect = settings.multiselect ? $uploader.data('multiselect')
          type = settings.type ? $uploader.data('type')

          "#{settings.host}/#
            tenant/#{settings.tenant}/
            #{if uploaderId then "uid/#{uploaderId}/" else ''}
            #{if multiselect then 's/multiselect/' else ''}
            #{if type then "t/#{type}/" else ''}
            prefix/#{prefix}
          ".replace /\ /g, ''

        getIframe = ->
          modalId = settings.modalId ? $uploader.data('modalId')
          if modalId
            $uploaderIframe = $("##{modalId}").find('.js-uploader-iframe')
          else
            $uploaderIframe = $uploader.find('.js-uploader-iframe')
          $uploaderIframe.first()

        initIframe = ->
          $iframe = getIframe()
          if $iframe.length
            iframeTemplate = _.template '''
              <iframe width='<%= width %>' height='<%= height %>' src='<%= src %>' frameborder='0'></iframe>
            '''

            $iframe.html iframeTemplate $.extend
              src: getUrl()
              width: '100%'
              height: 500
            , $iframe.data()

        openUploader = ->
          $iframe = getIframe()
          if $iframe.length
            $iframe.closest('div.modal').modal('show') if $.fn.modal?
            initIframe()
          else
            popupWindow = open getUrl(), 'NMD Media Lib', 'scrollbars=1, width=800, height=500'
            popupWindow.focus()

        if settings.open ? $uploader.data('open')
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