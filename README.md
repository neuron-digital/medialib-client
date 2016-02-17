# Medialib Client
Gem for integration MediaLib in ruby-application

## Installation

Install Gem
```ruby
gem 'medialib_client', github: 'Go-Promo/medialib-client'
```

Require jQuery-plugin in your assets
```coffee
#= require media_lib/jquery.nmdUploader
```

Use jQuery-plugin
```coffee
$('.js-uploader').nmdUploader
  host: %host%
  tenant: %tenant%
```

## Использование внешних инсертеров

`data-external-inserter="LifeTinyMceInserter"`

**example:**


```html

<div
      id="js-post-content"
      class="tiny-editor-area"
      data-prefix="{{path_prefix}}"
      data-type="image"
      data-external-inserter="LifeTinyMceInserter"
      data-style="690x420"></div>
      
```

**Inserter может вернуть результат из метода insert**

- MediaLib.INSERT_RESULT_PREVENT_CLOSE - не закрывать модальное окно

**Проброс data параметров**

Параметры будут доступны в Inserter'е при вставке в `@options.params`

```coffeescript

$("#" + editor.id).nmdUploader
    ...
    params:   {'side-image': true, blablabla: '123'}
              
```              