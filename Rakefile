#!/usr/bin/env rake

task :default => 'foodcritic'

desc "Runs foodcritic linter"
task :foodcritic do
  Rake::Task[:prepare_sandbox].execute

  if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
    sh "foodcritic -t correctness #{sandbox_path}/cookbooks/walletserver/"
    sh "foodcritic -t correctness #{sandbox_path}/cookbooks/coins/"
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

desc "Runs knife walletserver/coins cookbook test"
task :knife do
  Rake::Task[:prepare_sandbox].execute

  sh "bundle exec knife cookbook test walletserver -c test/.chef/knife.rb -o #{sandbox_path}/cookbooks/"
  sh "bundle exec knife cookbook test coins -c test/.chef/knife.rb -o #{sandbox_path}/cookbooks/"

end

task :prepare_sandbox do

  rm_rf sandbox_path
  mkdir_p sandbox_path
  cp_r Dir.glob("cookbooks"), sandbox_path
end

private
def sandbox_path
  File.join(File.dirname(__FILE__), "tmp")
end
