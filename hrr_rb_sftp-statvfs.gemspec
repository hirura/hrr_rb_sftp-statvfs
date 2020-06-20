require_relative 'lib/hrr_rb_sftp/statvfs/version'

Gem::Specification.new do |spec|
  spec.name          = "hrr_rb_sftp-statvfs"
  spec.version       = HrrRbSftp::Statvfs::VERSION
  spec.authors       = ["hirura"]
  spec.email         = ["hirura@gmail.com"]

  spec.summary       = %q{An hrr_rb_sftp extension that supports statvfs@openssh.com and fstatvfs@openssh.com extensions.}
  spec.description   = %q{An hrr_rb_sftp extension that supports statvfs@openssh.com and fstatvfs@openssh.com extensions.}
  spec.homepage      = "https://github.com/hirura/hrr_rb_sftp-statvfs"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = spec.homepage
  #spec.metadata["changelog_uri"] = spec.homepage

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sys-filesystem"
  spec.add_runtime_dependency "hrr_rb_sftp", "~> 0.2.0"
end
