module LicenseFinder
  class HexPackage < Package
    def package_manager
      'Hex'
    end
  end
end
