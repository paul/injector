require "spec_helper"

RSpec.describe Injector do
  RealHTTP = :real_http
  FakeHTTP = :fake_http

  module MyConfig
    extend Injector

    def http
      RealHTTP
    end
  end

  class MyService
    include MyConfig
  end

  subject(:my_service) { MyService.new }

  it "should make attributes available" do
    expect(my_service.http).to eq RealHTTP
  end

  it "should allow attributes to be substituted" do
    expect(my_service.http).to eq RealHTTP

    MyConfig.substitute(http: FakeHTTP) do
      expect(my_service.http).to eq FakeHTTP
    end

    expect(my_service.http).to eq RealHTTP
  end

  it "should allow attributes to be overridden in the initializer" do
    my_service = MyService.new(http: FakeHTTP)
    expect(my_service.http).to eq FakeHTTP
  end
end
