
module Injector
  def self.extended(mod)
    mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def self.included(klass)
        klass.send(:include, Injector::InitializerMethods)
      end
    RUBY
  end

  module InitializerMethods
    def initialize(**kwargs)
      kwargs.each do |name, value|
        define_singleton_method(name) { value }
      end
    end
  end

  def substitute(overrides)
    overrides.each do |name, object|
      __replace_method(name, object)
    end

    yield

    overrides.each do |name, _|
      __restore_method(name)
    end
  end

  private

  def __replace_method(name, value)
    stashed_method_name = __stashed_method_name(name)
    alias_method stashed_method_name, name
    define_method(name) { value }
  end

  def __restore_method(name)
    stashed_method_name = __stashed_method_name(name)
    alias_method name, stashed_method_name
    undef_method stashed_method_name
  end

  def __stashed_method_name(name)
    :"__substituted_method_#{name}"
  end
end

__END__

# Example Injector
module Clients
  extend Injector

  def http_client
    HTTP
  end

  def heroku_client
    HerokuClient
  end
end


# Example service object consuming config bucket
class HerokuProvisioner
  include Clients

  def initialize(app, option: nil, **kwargs)
    @app = app
    super(**kwargs)
  end
end

# Normal usage
provisioner = HerokuProvisioner.new(:app)

provisioner.http_client #=> HTTP

FakeHTTP = HTTP

# Substitute the object we're using with another one for the duration of the block
Clients.substitute(http_client: FakeHTTP) do
  provisioner.http_client #=> FakeHTTP
end

provisioner.http_client #=> HTTP

# Also override using kwargs
HerokuProvisioner.new(:app, http_client: FakeHTTP).http_client #=> FakeHTTP
