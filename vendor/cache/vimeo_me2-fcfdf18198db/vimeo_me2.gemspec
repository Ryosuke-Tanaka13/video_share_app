# -*- encoding: utf-8 -*-
# stub: vimeo_me2 1.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "vimeo_me2".freeze
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "http://mygemserver.com" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bo-oz".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-03-08"
  s.description = "Temp".freeze
  s.email = ["boristoet80@gmail.com".freeze]
  s.files = [".byebug_history".freeze, ".gitignore".freeze, ".rspec".freeze, ".travis.yml".freeze, "CODE_OF_CONDUCT.md".freeze, "Gemfile".freeze, "LICENSE.txt".freeze, "README.md".freeze, "Rakefile".freeze, "bin/console".freeze, "bin/setup".freeze, "fixtures/vcr_cassettes/vimeo-authenticated-user.yml".freeze, "fixtures/vcr_cassettes/vimeo-user-error.yml".freeze, "fixtures/vcr_cassettes/vimeo-user-videos-params.yml".freeze, "fixtures/vcr_cassettes/vimeo-user-videos.yml".freeze, "fixtures/vcr_cassettes/vimeo-user.yml".freeze, "fixtures/vcr_cassettes/vimeo-video-comments-add.yml".freeze, "fixtures/vcr_cassettes/vimeo-video-comments-delete.yml".freeze, "fixtures/vcr_cassettes/vimeo-video-comments-edit.yml".freeze, "fixtures/vcr_cassettes/vimeo-video-comments-view.yml".freeze, "fixtures/vcr_cassettes/vimeo-video-comments.yml".freeze, "fixtures/vcr_cassettes/vimeo-video-delete.yml".freeze, "fixtures/vcr_cassettes/vimeo-video-error.yml".freeze, "fixtures/vcr_cassettes/vimeo-video-update.yml".freeze, "fixtures/vcr_cassettes/vimeo-video.yml".freeze, "lib/vimeo_me2.rb".freeze, "lib/vimeo_me2/base.rb".freeze, "lib/vimeo_me2/http/http_request.rb".freeze, "lib/vimeo_me2/http/oauth/verify.rb".freeze, "lib/vimeo_me2/user.rb".freeze, "lib/vimeo_me2/user/album.rb".freeze, "lib/vimeo_me2/user/category.rb".freeze, "lib/vimeo_me2/user/channel.rb".freeze, "lib/vimeo_me2/user/feed.rb".freeze, "lib/vimeo_me2/user/followers.rb".freeze, "lib/vimeo_me2/user/following.rb".freeze, "lib/vimeo_me2/user/groups.rb".freeze, "lib/vimeo_me2/user/likes.rb".freeze, "lib/vimeo_me2/user/upload.rb".freeze, "lib/vimeo_me2/user/videos.rb".freeze, "lib/vimeo_me2/version.rb".freeze, "lib/vimeo_me2/video.rb".freeze, "lib/vimeo_me2/video/comment.rb".freeze, "lib/vimeo_me2/video/preset.rb".freeze, "vimeo_me2.gemspec".freeze]
  s.homepage = "https://github.com/bo-oz/vimeo_me2".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Temp".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.1.4"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<vcr>.freeze, ["~> 3.0.3"])
    s.add_development_dependency(%q<webmock>.freeze, ["~> 3.0.1"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.17.1"])
    s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<httparty>.freeze, ["~> 0.14.0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 2.1.4"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<vcr>.freeze, ["~> 3.0.3"])
    s.add_dependency(%q<webmock>.freeze, ["~> 3.0.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.17.1"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<httparty>.freeze, ["~> 0.14.0"])
  end
end
