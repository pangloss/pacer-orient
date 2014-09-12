require 'bundler'
Bundler::GemHelper.install_tasks

file 'pom.xml' => 'lib/pacer-orient/version.rb' do
  pom = File.read 'pom.xml'
  when_writing('Update pom.xml version number') do
    open 'pom.xml', 'w' do |f|
      pom.each_line do |line|
        line.sub!(%r{<gem.version>.*</gem.version>}, "<gem.version>#{ Pacer::Orient::VERSION }</gem.version>")
        line.sub!(%r{<orient.version>.*</orient.version>}, "<orient.version>#{ Pacer::Orient::ORIENT_VERSION }</orient.version>")
        line.sub!(%r{<pipes.version>.*</pipes.version>}, "<pipes.version>#{ Pacer::Orient::PIPES_VERSION }</pipes.version>")
        f << line
      end
    end
  end
end

file Pacer::Orient::JAR_PATH => 'pom.xml' do
  when_writing("Execute 'mvn package' task") do
    system('mvn clean package')
  end
end

task :note do
  puts "NOTE: touch lib/pacer-orient/version.rb (or rake touch) to force everything to rebuild"
end

task :build => [:note, Pacer::Orient::JAR_PATH]
task :install => [:note, Pacer::Orient::JAR_PATH]

desc 'Touch version.rb so that the jar rebuilds'
task :touch do
  system 'touch', 'lib/pacer-orient/version.rb'
end

