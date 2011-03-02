require 'lib/sox'
require 'tempfile'

class CacheTest
  include CacheInfo
end

describe "cache_info" do
  before do
    FileUtils.rm Dir["cache/test_*"]
    @cache_test = CacheTest.new
  end

  it "should just cache data" do

    @cache_test.cache_data :test_data, [1,2,3] do
      {:hello => 1}
    end

    cached_data = @cache_test.cache_data :test_data, [1,2,3] do
      raise 'should never be here'
    end

    cached_data.should == {:hello => 1}
  end

  it "should just cache a file" do
    @cache_test.cache_file :test_file, [:a,:b,:c] do
      (tmp = Tempfile.new(:test)).write('blah die blah')
      tmp
    end

    file = @cache_test.cache_file :test_file, [:a, :b, :c] do
      raise 'should never be here'
    end

    file.read.should == 'blah die blah'

  end
end
