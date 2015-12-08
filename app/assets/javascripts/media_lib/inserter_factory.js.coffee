window.MediaLib ||= {}

# Абстрактная фабрика для создания стратегий вставки
class MediaLib.InserterFactory
  constructor: (@settings) ->
  createInserter: ->
    uploader = @settings.uploader
    model = @settings.model
    switch uploader.type
      when 'audio'
        if model.type is 'audio'
          new MediaLib.AudioInserter uploader, model
      when 'image'
        if model.type is 'image'
          new MediaLib.SingleImageInserter uploader, model
      when 'video'
        if model.type is 'video'
          switch uploader.site
            when 'lifenews.ru'
              new MediaLib.IFrameVideoInserter @settings.host, uploader, model
            else
              new MediaLib.VideoInserter @settings.host, uploader, model
      when 'multi_image'
        if model.type is 'image'
          switch uploader.site
            when 'heat.ru'
              new MediaLib.HeatMultiImageInserter uploader, model
            when 'lifenews.ru'
              new MediaLib.LifenewsMultiImageInserter uploader, model
            when 'izvestia.ru'
              new MediaLib.IzvestiaMultiImageInserter uploader, model
      when 'tinymce'
        switch uploader.site
          when 'rusnovosti.ru'
            new MediaLib.RusnovostiTinyMCE3Inserter @settings.host, uploader, model
          else
            new MediaLib.TinyMCE3Inserter @settings.host, uploader, model
      when 'tinymce4'
        new MediaLib.TinyMCE4Inserter @settings.host, uploader, model
      when 'same_image'
        if model.type is 'image'
          new MediaLib.SameImageInserter uploader, model
      when 'gallery_image'
        if model.type is 'image'
          new MediaLib.HeatGalleryImageInserter uploader, model
      else
        throw new Error('Undefined Inserter')

# Базовый абстрактный класс стратегии
class MediaLib.BaseInserter
  constructor: (@uploader, @model) ->
  insert: ->
    throw new Error("NotImplementedException")

# Стратегия вставки аудио-модели
class MediaLib.AudioInserter extends MediaLib.BaseInserter
  insert: ($uploader) ->
    $uploader.find('.js-uploader-input').val @model.static_name
    $uploader.find('.js-uploader-input').trigger 'change'

    $playerContainer = $uploader.find('.js-player-container')
    if $playerContainer.length
      $player = $('<div>')
      $playerContainer.html $player
      $player.nmdVideoPlayerJw setup:
        file: @model.static_url
        height: 30

# Стратегия вставки видео-модели через iframe, передаём static_name
class MediaLib.VideoInserter extends MediaLib.BaseInserter
  constructor: (@host, @uploader, @model) ->
  insert: ($uploader) ->
    throw new Error("host isn't defined") unless @host

    $uploader.find('.js-uploader-duration').val @model.duration
    $uploader.find('.js-uploader-input').val @model.static_name
    $uploader.find('.js-uploader-input').trigger 'change'

    $uploaderVideo = $uploader.find('.js-uploader-video')
    if $uploaderVideo.length
      $player = $("<iframe src='//#{@host}/embed/#{@model.hash}' frameborder='0' allowfullscreen class='medialib-video'>")
      $uploaderVideo.html $player

# Стратегия вставки видео-модели через iframe, передаём hash
class MediaLib.IFrameVideoInserter extends MediaLib.BaseInserter
  constructor: (@host, @uploader, @model) ->
  insert: ($uploader) ->
    throw new Error("host isn't defined") unless @host

    $uploader.find('.js-uploader-duration').val @model.duration
    $uploader.find('.js-uploader-input').val @model.hash
    $uploader.find('.js-uploader-input').trigger 'change'

    $uploaderVideo = $uploader.find('.js-uploader-video')
    if $uploaderVideo.length
      $player = $("<iframe src='//#{@host}/embed/#{@model.hash}' frameborder='0' allowfullscreen class='medialib-video'>")
      $uploaderVideo.html $player

# Стратегия вставки одного изображения
class MediaLib.SingleImageInserter extends MediaLib.BaseInserter
  insert: ($uploader) ->
    url = @model.static_url.replace(/(\.\w{3,4})$/, "__#{@uploader.style}$1")
    $uploader.find('.js-uploader-img').attr 'src', url

    $uploader.find('.js-uploader-input').val @model.original_name
    $uploader.find('.js-uploader-input').trigger 'change'

# Стратегия вставки множества стилей одного изображения
class MediaLib.SameImageInserter extends MediaLib.BaseInserter
  insert: ($uploader) ->
    $uploader.find('.js-uploader-input').val @model.original_name
    $uploader.find('.js-uploader-input').trigger 'change'

    $imageField = $uploader.find('.js-uploader-same-image')
    imageTemplate = _.template '
      <div class="span3">
        <div class="thumbnail">
          <img alt="" src="<%= url %>">
          <div class="caption"><%= style %></div>
        </div>
      </div>'
    $imageField.empty()
    _.each @uploader.styles, (style) =>
      $imageField.append imageTemplate
        url: @model.static_url.replace(/(\.\w{3,4})$/, "__#{style}$1")
        style: style

# Стратегия вставки одного стиля разных изображений
class @MediaLib.MultiImageInserter extends MediaLib.BaseInserter
  insertByTemplate: ($uploader, imageTemplate) ->
    $imageField = $uploader.find('.js-uploader-multi-image')
    number = $imageField.find('li').length
    $imageField.append imageTemplate
      number: number
      original_name: @model.original_name
      description: @model.description
      url: @model.static_url.replace(/(\.\w{3,4})$/, "__#{@uploader.style}$1")

# Стратегия вставки одного стиля разных изображений на сайте lifenews.ru
class MediaLib.LifenewsMultiImageInserter extends MediaLib.MultiImageInserter
  insert: ($uploader) ->
    imageTemplate = _.template '
      <li>
        <input id="gallery_gallery_files_attributes_<%= number %>_image_file_name" name="gallery[gallery_files_attributes][<%= number %>][image_file_name]" type="hidden" value="<%= original_name %>">
        <div class="thumbnail">
          <img src="<%= url %>" alt="">
        </div>
      </li>'

    @insertByTemplate $uploader, imageTemplate

# Стратегия вставки одного стиля разных изображений на сайте super.ru
class MediaLib.HeatMultiImageInserter extends MediaLib.MultiImageInserter
  insert: ($uploader) ->
    imageTemplate = _.template '
      <li class="span3">
        <img alt="" class="thumbnail" src="<%= url %>">
        <div class="caption">
          <input id="post_extra_double_image_files_attributes_<%= number %>_image_file_name" name="post[extra_double_image_files_attributes][<%= number %>][image_file_name]" type="hidden" value="<%= original_name %>">
        </div>
      </li>'

    @insertByTemplate $uploader, imageTemplate

# Стратегия вставки фотграфий галерей на сайте super.ru
class MediaLib.HeatGalleryImageInserter extends MediaLib.BaseInserter
  insertByTemplate: ($uploader, imageTemplate) ->
    $imageField = $uploader.find('.js-uploader-gallery-image')
    number = $imageField.find('li').length
    $imageField.append imageTemplate
      number: number
      original_name: @model.original_name
      description: @model.description
      url: @model.static_url.replace(/(\.\w{3,4})$/, "__#{@uploader.style}$1")

  insert: ($uploader) ->
    imageTemplate = _.template '
      <li>
        <input id="post_post_gallery_files_attributes_<%= number %>_image_file_name" name="post[post_gallery_files_attributes][<%= number %>][image_file_name]" type="hidden" value="<%= original_name %>">
        <div class="control-group">
          <div class="control-label"><label for="post_post_gallery_files_attributes_<%= number %>_image_file_name">Изображение</label></div>
          <div class="controls">
            <img alt="" class="thumbnail" src="<%= url %>">
          </div>
        </div>
        <div class="control-group">
          <div class="control-label"><label for="post_post_gallery_files_attributes_<%= number %>_placement_index">Положение в галерее</label></div>
          <div class="controls"><input class="span2" id="post_post_gallery_files_attributes_<%= number %>_placement_index" min="0" name="post[post_gallery_files_attributes][<%= number %>][placement_index]" type="number" value="0"></div>
        </div>
        <div class="control-group">
          <div class="control-label"><label for="post_post_gallery_files_attributes_<%= number %>_description">Описание</label></div>
          <div class="controls"><textarea class="span8" cols="40" id="post_post_gallery_files_attributes_<%= number %>_description" maxlength="200" name="post[post_gallery_files_attributes][<%= number %>][description]" rows="5"><%= description %></textarea></div>
        </div>
        <div class="control-group">
          <div class="control-label"><label for="post_post_gallery_files_attributes_<%= number %>_source">Источник</label></div>
          <div class="controls"><input id="post_post_gallery_files_attributes_<%= number %>_source" name="post[post_gallery_files_attributes][<%= number %>][source]" size="30" type="text"></div>
        </div>
        <div class="clearfix"></div>
        <hr>
      </li>'

    @insertByTemplate $uploader, imageTemplate

# Стратегия вставки различного контента в редактор TinyMCE 3
class MediaLib.TinyMCE3Inserter extends MediaLib.BaseInserter
  constructor: (@host, @uploader, @model) ->
  insert: ($uploader) ->
    switch @model.type
      when 'image'
        if @uploader.style?
          src = @model.static_url.replace(/(\.\w{3,4})$/, "__#{@uploader.style}$1")
        else
          src = @model.static_url
        template = _.template '<img src="<%= src %>" alt="<%= description %>">'
        content = template
          src: src
          description: @model.description
      when 'video'
        new Error("host isn't defined") unless @host

        template = _.template "<iframe src='//<%= host %>/embed/<%= hash %>' frameborder='0' allowfullscreen class='medialib-video'></iframe>"
        content = template
          host: @host
          hash: @model.hash
      when 'audio'
        template = _.template '
          <audio class="audioPlayer" controls>
            <source src="<%= src %>" type="audio/mpeg">
          </audio>'
        content = template
          src: @model.player_audio
    ed = tinyMCE.get @model.uploaderId
    ed.execCommand 'mceInsertContent', false, content

# Стратегия вставки различного контента в редактор TinyMCE 4
class MediaLib.TinyMCE4Inserter extends MediaLib.TinyMCE3Inserter
  constructor: (@host, @uploader, @model) -> # to override
  insert: ($uploader) ->
    switch @model.type
      when 'image'
        if @uploader.style?
          src = @model.static_url.replace(/(\.\w{3,4})$/, "__#{@uploader.style}$1")
        else
          src = @model.static_url
        template = _.template @getImageTemplate()
        content = template
          src: src
          description: @model.description
      when 'video'
        new Error("host isn't defined") unless @host

        template = _.template @getVideoTemplate()
        content = template
          host: @host
          hash: @model.hash
      when 'audio'
        template = _.template @getAudioTemplate()
        content = template
          src: @model.player_audio
    ed = tinyMCE.get @model.uploaderId
    ed.execCommand 'mceInsertContent', false, content

  getImageTemplate: -> '<p><img src="<%= src %>" alt="<%= description %>"></p>'
  getVideoTemplate: -> '<iframe src="//<%= host %>/embed/<%= hash %>" frameborder="0" allowfullscreen class="medialib-video"></iframe>'
  getAudioTemplate: ->
    '<audio class="audioPlayer" controls>
       <source src="<%= src %>" type="audio/mpeg">
     </audio>'

# Стратегия вставки различного контента в редактор TinyMCE 3
class MediaLib.RusnovostiTinyMCE3Inserter extends MediaLib.BaseInserter
  constructor: (@host, @uploader, @model) ->
  insert: ($uploader) ->
    switch @model.type
      when 'image'
        if @uploader.style?
          src = @model.static_url.replace(/(\.\w{3,4})$/, "__#{@uploader.style}$1")
        else
          src = @model.static_url
        template = _.template '<img src="<%= src %>" alt="<%= description %>">'
        content = template
          src: src
          description: @model.description
      when 'video'
        new Error("host isn't defined") unless @host

        template = _.template "<iframe src='//<%= host %>/embed/<%= hash %>' frameborder='0' allowfullscreen class='medialib-video'></iframe>"
        content = template
          host: @host
          hash: @model.hash
      when 'audio'
        template = _.template '<div class="jw-audio js-jw-audio" data-file="<%= file %>" data-description="<%= description %>">Audio loading...</div>'
        content = template
          file: @model.player_audio
          description: @model.description
    ed = tinyMCE.get @model.uploaderId
    ed.execCommand 'mceInsertContent', false, content
