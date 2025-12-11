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

  it "is thread-safe when called in the block form" do
    TinyGID.app = "main"

    threads = 10.times.map do |i|
      Thread.new do
        TinyGID.app("thread-#{i}") do
          expect(TinyGID.app).to eq("thread-#{i}")
          expect(TinyGID.Product(123).to_s).to eq("gid://thread-#{i}/Product/123")

          # Force some contention
          sleep(rand(0.001..0.005))
        end

        # Check that outside the thread it's "main"
        TinyGID.app
      end
    end

    # Main thread never changed
    expect(TinyGID.app).to eq("main")
    expect(TinyGID.Product(1)).to eq("gid://main/Product/1")

    values = threads.map(&:value)
    expect(values).to eq %w[main] * 10
  end

  it "adds query string parameters" do
    TinyGID.app = "shopify"

    gid = TinyGID::InventoryItem(123, :item_id => 456, :whatever => "A B")
    expect(gid).to eq("gid://shopify/InventoryItem/123?item_id=456&whatever=A+B")
  end

  it "encodes the ID value using the x-www-form-urlencoded content type" do
    TinyGID.app = "foo"

    gid = TinyGID::User("A B")
    expect(gid).to eq("gid://foo/User/A+B")
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
