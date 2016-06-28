require 'json'

PACKAGE_FORMAT = /\* (\w+) (?:([\d\.]+) )?\(Hex package\)/

module LicenseFinder
  class Hex < PackageManager
    def current_packages
      mix_deps_output.map do |name, version|
        HexPackage.new(
          name,
          version,
          hex_info(name),
          logger: logger,
          install_path: deps_path.join(name)
        )
      end
    end

    private

    def mix_deps_output
      command = 'mix deps'
      output, success = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{output}" unless success

      output
        .each_line
        .select { |line| line.start_with?('*') && line.include?('(Hex package)') }
        .map do |line|
          match_data = PACKAGE_FORMAT.match(line)
          [match_data[1], match_data[2]]
        end
    end

    def hex_info(name)
      response = HTTParty.get("https://hex.pm/api/packages/#{name}")
      if response.code == 200
        JSON.parse(response.body).fetch('meta', {})
      else
        {}
      end
    end

    def package_path
      project_path.join('mix.exs')
    end

    def deps_path
      project_path.join('deps')
    end

    def capture(command)
      [`#{command}`, $?.success?]
    end
  end
end
