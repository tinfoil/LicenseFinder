require 'json'

PACKAGE_FORMAT = /\* (\w+)(?:(.*))? \(.*\) \(mix\)/

module LicenseFinder
  class Hex < PackageManager
    def current_packages
      mix_deps_output.map do |name, version|
        HexPackage.new(
          name,
          version,
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
        .select { |line| line.start_with?('*') && line.include?('(mix)') }
        .map do |line|
          match_data = PACKAGE_FORMAT.match(line)
          [match_data[1], match_data[2]]
        end
    end

    def package_path
      project_path.join('mix.exs')
    end

    def deps_path
      project_path.join('deps')
    end

    def capture(command)
      [`MIX_ENV=prod #{command}`, $?.success?]
    end
  end
end
