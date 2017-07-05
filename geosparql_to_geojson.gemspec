# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geosparql_to_geojson/version'

Gem::Specification.new do |spec|
  spec.name          = 'geosparql_to_geojson'
  spec.version       = GeosparqlToGeojson::VERSION
  spec.authors       = ['Callum Neve-Jones']
  spec.email         = ['nevejonesc@parliament.uk']

  spec.summary       = %q{Converts GeoSparql to GeoJSON}
  spec.description   = %q{Converts GeoSparql to GeoJSON}
  spec.homepage      = 'https://github.com/ukparliament/geosparql-to-geojson'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'json-schema', '~> 2.8'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.12'
end
