# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amazon_associate}
  s.version = "0.6.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Pickett"]
  s.date = %q{2009-06-30}
  s.description = %q{interfaces with Amazon Associate's API using Hpricot}
  s.email = %q{dpickett@enlightsolutions.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".autotest",
     ".gitignore",
     ".project",
     "CHANGELOG",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "amazon_associate.gemspec",
     "lib/amazon_associate.rb",
     "lib/amazon_associate/cache_factory.rb",
     "lib/amazon_associate/caching_strategy.rb",
     "lib/amazon_associate/caching_strategy/base.rb",
     "lib/amazon_associate/caching_strategy/filesystem.rb",
     "lib/amazon_associate/configuration_error.rb",
     "lib/amazon_associate/element.rb",
     "lib/amazon_associate/request.rb",
     "lib/amazon_associate/request_error.rb",
     "lib/amazon_associate/response.rb",
     "test/amazon_associate/browse_node_lookup_test.rb",
     "test/amazon_associate/cache_test.rb",
     "test/amazon_associate/caching_strategy/filesystem_test.rb",
     "test/amazon_associate/cart_test.rb",
     "test/amazon_associate/request_test.rb",
     "test/test_helper.rb",
     "test/utilities/filesystem_test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/dpickett/amazon_associate}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Amazon Associates API Interface using Hpricot}
  s.test_files = [
    "test/amazon_associate/browse_node_lookup_test.rb",
     "test/amazon_associate/cache_test.rb",
     "test/amazon_associate/caching_strategy/filesystem_test.rb",
     "test/amazon_associate/cart_test.rb",
     "test/amazon_associate/request_test.rb",
     "test/test_helper.rb",
     "test/utilities/filesystem_test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
