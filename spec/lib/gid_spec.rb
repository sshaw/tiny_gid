require "gid"

RSpec.describe "GID" do
  after :all do
    Object.send(:remove_const, :GID) if Object.const_defined?(:GID)
    Kernel.send(:undef_method, :gid) if Kernel.respond_to?(:gid)

    loaded_path = $LOADED_FEATURES.find { |p| p.end_with?("/gid.rb") }
    $LOADED_FEATURES.delete(loaded_path) if loaded_path
  end

  it "points to TinyGID" do
    expect(GID).to eq TinyGID
  end

  it "defines a gid method" do
    gid.app = "shopify"

    expect(gid::Product(123).to_s).to eq("gid://shopify/Product/123")
    expect(gid::ProductVariant(456).to_s).to eq("gid://shopify/ProductVariant/456")
  end
end
