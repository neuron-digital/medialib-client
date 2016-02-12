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
