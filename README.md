# Medialib Client
Gem for integration MediaLib in ruby-application

## Installation

Install Gem
```ruby
gem 'medialib_client', github: 'Go-Promo/medialib-client'
gem 'rails-backbone', github: 'codebrew/backbone-rails'
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

## Examples