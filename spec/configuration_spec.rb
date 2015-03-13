require 'spec_helper'

module HttpEventstore
  describe Configuration do

    let(:new_host) {'test.host.com'}
    let(:new_port) {3000}

    before :each do
      HttpEventstore.configure do |config|
        config.host = new_host
        config.port = new_port
      end
    end

    specify 'sets the appropriate configuration properties' do
      config = HttpEventstore.configuration
      expect(config.host).to eq(new_host)
      expect(config.port).to eq(new_port)
    end

    specify 'reset configuration properties do default values' do
      HttpEventstore.reset
      config = HttpEventstore.configuration
      expect(config.host).to eq('127.0.0.1')
      expect(config.port).to eq(2113)
    end
  end
end
