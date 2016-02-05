module LicenseFinder
  class HexPackage < Package
    def initialize(name, version, spec, options={})
      super(
        name,
        version,
        options.merge(
          summary: spec['description'],
          homepage: spec['links'].values.first,
          spec_licenses: spec['licenses']
        )
      )
    end
  end
end
