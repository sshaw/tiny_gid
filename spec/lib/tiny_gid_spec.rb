require "tiny_gid"

RSpec.describe TinyGID do
  it "does not define GID" do
    expect(defined?(GID)).to be_nil
  end

  # Defined!
  # it "does not define gid" do
  #   expect(defined?(gid)).to be_nil
  # end

  it "uses the globally configured app name by default" do
    TinyGID.app = "shopify"

    expect(TinyGID.Product(123)).to eq("gid://shopify/Product/123")
    expect(TinyGID.ProductVariant(456)).to eq("gid://shopify/ProductVariant/456")
  end

  it "allows overriding the app name for the duration of a block" do
    TinyGID.app = "shopify"

    TinyGID.app("something-amaaaazing") do
      expect(TinyGID.User(1)).to eq("gid://something-amaaaazing/User/1")
      expect(TinyGID.Post(99)).to eq("gid://something-amaaaazing/Post/99")
    end

    # after the block the original value is restored
    expect(TinyGID.User(1)).to eq("gid://shopify/User/1")
  end

  it "supports extra query parameters on certain resource types" do
    TinyGID.app = "shopify"

    gid = TinyGID::InventoryItem(123, :item_id => 456)
    expect(gid).to eq("gid://shopify/InventoryItem/123?item_id=456")
  end

  it "restores the previous app value even when an exception is raised inside the block" do
    TinyGID.app = "shopify"

    begin
      TinyGID.app("boom") do |gid|
        gid::User(5)
        raise "boom!"
      end
    rescue RuntimeError
    end

    expect(TinyGID.app).to eq("shopify")
    expect(TinyGID::User(7)).to eq("gid://shopify/User/7")
  end
end
