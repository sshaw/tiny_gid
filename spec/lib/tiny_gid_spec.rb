require "tiny_gid"

RSpec.describe TinyGID do
  it "does not define GID" do
    expect(defined?(GID)).to be_nil
  end

  # Defined!
  # it "does not define gid" do
  #   expect(defined?(gid)).to be_nil
  # end

  describe ".gid" do
    it "uses the globally configured app name by default" do
      described_class.app = "shopify"

      expect(described_class.Product(123)).to eq("gid://shopify/Product/123")
      expect(described_class.ProductVariant(456)).to eq("gid://shopify/ProductVariant/456")
    end

    it "allows overriding the app name for the duration of a block" do
      described_class.app = "shopify"

      described_class.app("something-amaaaazing") do
        expect(described_class.User(1)).to eq("gid://something-amaaaazing/User/1")
        expect(described_class.Post(99)).to eq("gid://something-amaaaazing/Post/99")
      end

      # after the block the original value is restored
      expect(described_class.User(1)).to eq("gid://shopify/User/1")
    end

    it "is thread-safe when called in the block form" do
      described_class.app = "main"

      threads = 10.times.map do |i|
        Thread.new do
          described_class.app("thread-#{i}") do
            expect(described_class.app).to eq("thread-#{i}")
            expect(described_class.Product(123)).to eq("gid://thread-#{i}/Product/123")

            # Force some contention
            sleep(rand(0.001..0.005))
          end

          # Check that outside the thread it's "main"
          described_class.app
        end
      end

      # Main thread never changed
      expect(described_class.app).to eq("main")
      expect(described_class.Product(1)).to eq("gid://main/Product/1")

      values = threads.map(&:value)
      expect(values).to eq %w[main] * 10
    end

    it "adds query string parameters" do
      described_class.app = "shopify"

      gid = described_class::InventoryItem(123, :item_id => 456, :whatever => "A B")
      expect(gid).to eq("gid://shopify/InventoryItem/123?item_id=456&whatever=A+B")
    end

    it "encodes the ID value using the x-www-form-urlencoded content type" do
      described_class.app = "foo"

      gid = described_class::User("A B")
      expect(gid).to eq("gid://foo/User/A+B")
    end

    it "restores the previous app value even when an exception is raised inside the block" do
      described_class.app = "shopify"

      begin
        described_class.app("boom") do |gid|
          gid::User(5)
          raise "boom!"
        end
      rescue RuntimeError
      end

      expect(described_class.app).to eq("shopify")
      expect(described_class::User(7)).to eq("gid://shopify/User/7")
    end
  end

  describe ".parse" do
    %w[gid gid:// gid://foo/Bar gid//foo gid://foo/Bar/ gid//foo/Bar/123].each do |id|
      context "given #{id}" do
        it "raises an ArgumentError" do
          expect { described_class.parse(id) }.to raise_error(ArgumentError, "'#{id}' is not a valid global id")
        end
      end
    end

    it "parses a valid global id" do
      parsed = described_class.parse("gid://foo/User/123")
      expect(parsed).to eq %w[foo User 123]

      parsed = described_class.parse("gid://foo-hoo/SomeUser/123-456")
      expect(parsed).to eq %w[foo-hoo SomeUser 123-456]
    end

    it "parses a valid global id with a query string" do
      parsed = described_class.parse("gid://foo/User/123?x=123&y=456")
      expect(parsed).to eq ["foo", "User", "123", "x" => "123", "y" => "456"]

      parsed = described_class.parse("gid://foo/User/123?")
      expect(parsed).to eq ["foo", "User", "123"]
    end
  end

  describe ".to_sc" do
    it "returns the scalar id" do
      id = described_class.to_sc("gid://foo/User/123")
      expect(id).to eq "123"

      id = described_class.to_sc("gid://foo/User/123?x=1")
      expect(id).to eq "123"
    end
  end
end
