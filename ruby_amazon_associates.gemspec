# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby_amazon_associates}
  s.version = "0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Pickett", "Herryanto Siatono"]
  s.autorequire = %q{name}
  s.date = %q{2008-11-10}
  s.email = ["dpickett@enlightsolutions.com", "herryanto@pluitsolutions.com"]
  s.extra_rdoc_files = ["README", "CHANGELOG"]
  s.files = ["lib/amazon/cache_factory.rb", "lib/amazon/caching_strategy/base.rb", "lib/amazon/caching_strategy/filesystem.rb", "lib/amazon/caching_strategy.rb", "lib/amazon/configuration_error.rb", "lib/amazon/ecs.rb", "lib/amazon/element.rb", "lib/amazon/request_error.rb", "lib/amazon/response.rb", "lib/amazon.rb", "README", "test/amazon/browse_node_lookup_test.rb", "test/amazon/cache_test.rb", "test/amazon/caching_strategy/filesystem_test.rb", "test/amazon/cart_test.rb", "test/amazon/ecs_test.rb", "CHANGELOG"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/dpickett/ruby_amazon_associates/tree/master}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Generic Amazon Associates Web Service (Formerly ECS) REST API. Supports ECS 4.0.}
  s.test_files = ["test/amazon/browse_node_lookup_test.rb", "test/amazon/cache_test.rb", "test/amazon/caching_strategy/filesystem_test.rb", "test/amazon/cart_test.rb", "test/amazon/ecs_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.6"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.6"])
  end
end
