# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby_amazon_associates}
  s.version = "0.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Herryanto Siatono", "Dan Pickett"]
  s.autorequire = %q{name}
  s.date = %q{2008-10-21}
  s.email = ["herryanto@pluitsolutions.com, dpickett@enlightsolutions.com"]
  s.extra_rdoc_files = ["README", "CHANGELOG"]
  s.files = ["test/amazon/browse_node_lookup_test.rb", "test/amazon/cart_test.rb", "test/amazon/ecs_test.rb", "README", "CHANGELOG"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/dpickett/ruby_amazon_associates/tree/master}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.textile"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Generic Amazon Associates Web Service (Formerly ECS) REST API. Supports ECS 4.0.}
  s.test_files = ["test/amazon/browse_node_lookup_test.rb", "test/amazon/cart_test.rb", "test/amazon/ecs_test.rb"]

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
