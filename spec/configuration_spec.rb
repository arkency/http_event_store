require 'spec_helper'

module HttpEventstore
  describe Configuration do

    let(:new_endpoint)  { 'test.host.com' }
    let(:new_port)      { 3000 }
    let(:new_page_size) { 50 }

    before :each do
      HttpEventstore.configure do |config|
        config.endpoint = new_endpoint
        config.port = new_port
        config.page_size = new_page_size
      end
    end

    specify 'sets the appropriate configuration properties' do
      config = HttpEventstore.configuration
      expect(config.endpoint).to eq(new_endpoint)
      expect(config.port).to eq(new_port)
      expect(config.page_size).to eq(new_page_size)
    end

    specify 'reset configuration properties do default values' do
      HttpEventstore.reset
      config = HttpEventstore.configuration
      expect(config.endpoint).to eq('127.0.0.1')
      expect(config.port).to eq(2113)
      expect(config.page_size).to eq(20)
    end
  end
end
