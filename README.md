# TinyGID

![TinyGID CI Status](https://github.com/sshaw/tiny_gid/actions/workflows/ci.yml/badge.svg "TinyGID CI Status")

Tiny class to build Global ID (gid://) strings from scalar values.

## Usage

`gem install tiny_gid` or for Bundler: `gem "tiny_gid", :require => "gid"`


Setting an app name is required. If Rails is installed `Rails.application.name` is used.

```rb
require "gid"

gid.app = "shopify"

gid::Product(123)        # "gid://shopify/Product/123"
gid::ProductVariant(123) # "gid://shopify/ProductVariant/123"
gid::InventoryLevel(123, :inventory_item_id => 456) # "gid://shopify/InventoryLevel/123?inventory_item_id=456"

# Use something besides gid.app for the duration of the block:
gid.app("something-amaaaazing") do
  gid::User(1)  # "gid://something-amaaaazing/User/1"
  gid::Post(99) # "gid://something-amaaaazing/User/99"
end
```

This will also import the `GID` class:
```rb
gid = GID.new("shopify")
gid::Product(123)        # "gid://shopify/Product/123"

# You don't have to use :: of course ;)
gid.Product(123) # "gid://shopify/Product/123"
```

If you don't want the (pesky?) `gid` method you can require: `tiny_gid/gid` which gives you `GID` only.

If `GID` creates a conflict in the top-level namespace use `TinyGID`:
```rb
require "tiny_gid"

TinyGID.app = "shopify"
TinyGID::Product(123) # "gid://shopify/Product/123"

TinyGID.app("something-amaaaazing") do |gid|
  gid::User(1) # "gid://something-amaaaazing/User/1"
end

gid = TinyGID.new("shopify")
gid.Product(123)
```

## Why Not Use GlobalID‽

[GlobalID](https://github.com/rails/globalid) is nice but it primarily deals with IDs backed by an instance of a class, e.g. Rails model, whereas
TinyGID is for scalars.

GlobalID does indeed have version that can be used with scalars but it's a bit verbose and not good for developer productivity:
```rb
URI::GID.build(:app => "foo", :model_name => "User", :model_id => "123", :params => { :foo => "bar" })
```

Don't yah think?

## ID Encoding/Escaping

Using application/x-www-form-urlencoded encoding to match GlobalID. Should probably support URL encoding too.

To put that in 21st century speak: spaces with be replaced with `+` not `%20`.

## Signed Global IDs

No support. Use GlobalID :)

## Author

Skye Shaw [skye.shaw -AT- gmail.com]

## License

Released under the MIT License: http://www.opensource.org/licenses/MIT
