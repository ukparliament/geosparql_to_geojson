# GeosparqlToGeojson

[GeosparqlToGeojson][geosparqltogeojson] is a gem created by the [Parliamentary Digital Service][pds] to take [GeoSparql][geosparql] data and convert it into [GeoJSON][geojson] data.

[![Gem][shield-gem]][info-gem] [![Build Status][shield-travis]][info-travis] [![Test Coverage][shield-coveralls]][info-coveralls] [![License][shield-license]][info-license]

> **NOTE:** This gem is in active development and is likely to change at short notice. It is not recommended that you use this in any production environment.

### Contents
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Getting Started with Development](#getting-started-with-development)
  - [Running the tests](#running-the-tests)
- [Contributing](#contributing)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Requirements
[GeosparqlToGeojson][geosparqltogeojson] requires the following:
* [Ruby][ruby] - [click here][ruby-version] for the exact version
* [Bundler][bundler]

## Installation
```bash
gem 'geosparql_to_geojson'
```

## Usage
This gem's main function is taking a [GeoSparql][geosparql] string and converting it into [GeoJSON][geojson].

Calling `GeosparqlToGeojson#convert_to_geojson` and passing in valid GeoSparql string will convert the GeoSparql to GeoJSON and return a GeosparqlToGeojson::GeoJson object.

Properties can optionally be passed in as well as whether the data should be reversed during the convertion.

```ruby
geosparql = 'POINT(0.1, 51.5)'
properties = {name: 'London'}

point = GeosparqlToGeojson.convert_to_geojson(geosparql_values: geosparql, geosparql_properties: properties, reverse: true)
#=> GeosparqlToGeojson::GeoJson
```

Calling `point.geojson` will return a GeoJSON string. For example:

```json
{"type": "FeatureCollection",
  "features": [
    {
       "type": "Feature",
       "geometry": {
         "type": "Point",
         "coordinates": [
          51.5,
          0.1
        ]
      },
      "properties": {"name": "London"}
    }
  ]
}
```



Calling `point.validate` will return a `GeosparqlToGeojson::Validator` object which can be used to validate the generated GeoJSON.

```ruby
validated_geojson = GeosparqlToGeojson::Validator.new(point)

validated_geojson.valid?
#=> true

validated_geojson.errors
#=> []
```

## Getting Started with Development
To clone the repository and set up the dependencies, run the following:

```bash
git clone https://github.com/ukparliament/geosparql-to-geojson.git
cd geosparql_to_geojson
bundle install
```

### Running the tests
We use [RSpec][rspec] as our testing framework and tests can be run using:

```bash
bundle exec rspec
```

## Contributing
If you wish to submit a bug fix or feature, you can create a pull request and it will be merged pending a code review.

1. Fork the repository
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Ensure your changes are tested using [Rspec][rspec]
1. Create a new Pull Request



## License
[GeosparqlToGeojson][geosparqltogeojson] is licensed under the [Open Parliament Licence][info-license].

[ruby]:               https://www.ruby-lang.org/en/
[bundler]:            http://bundler.io
[rspec]:              http://rspec.info 
[geosparqltogeojson]: https://github.com/ukparliament/geosparql-to-geojson
[pds]:                https://www.parliament.uk/mps-lords-and-offices/offices/bicameral/parliamentary-digital-service/
[geosparql]:          http://www.opengis.net/doc/IS/geosparql/1.0
[geojson]:            https://tools.ietf.org/html/rfc7946#appendix-A.2
[ruby-version]:       https://github.com/ukparliament/geosparql-to-geojson/blob/master/.ruby-version


[info-gem]:   https://rubygems.org/gems/geosparql-to-geojson
[shield-gem]: https://img.shields.io/gem/v/geosparql-to-geojson.svg

[info-travis]:   https://travis-ci.org/ukparliament/geosparql-to-geojson
[shield-travis]: https://img.shields.io/travis/ukparliament/geosparql-to-geojson.svg

[info-coveralls]:   https://coveralls.io/github/ukparliament/geosparql-to-geojson
[shield-coveralls]: https://img.shields.io/coveralls/ukparliament/geosparql-to-geojson.svg

[info-license]:   http://www.parliament.uk/site-information/copyright/open-parliament-licence/
[shield-license]: https://img.shields.io/badge/license-Open%20Parliament%20Licence-blue.svg
