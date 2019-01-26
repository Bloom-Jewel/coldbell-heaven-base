ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'rails/commands/server'
module Rails; end
class Rails::Server
  def default_options
    super.merge(Host: '0.0.0.0', Port: 2838)
  end
end

->(){
  # Rails ARGV flush mitigation
  pid = Process.pid
  cmdline = File.read(File.join('','proc',String(pid),'cmdline')).split("\0")
  
  is_valid = ->(op){
    od = File.join('','proc',String(op))
    next false unless File.exists?(od)
    ocl = File.read(File.join(od,'cmdline'))
    next false unless ocl.include?('rails')
    true
  }
  next unless ($0).end_with?('bin/rails')
  
  if ARGV.empty? # load
    fpid = File.expand_path(File.join('..','tmp','pids',"#{pid}.spc"), __dir__)
    if File.exists?(fpid) and is_valid.call(pid) then
      Marshal.load(File.binread(fpid)).tap do |h|
        ARGV.push(*h[:args])
      end # recover
    end
  end
  {}.tap do |h|
    h[:pid] = pid
    h[:cmdline] = cmdline
    h[:args] = ARGV.dup
    fn = File.join("tmp","pids","#{pid}.spc")
    File.binwrite(fn,Marshal.dump(h))
  end
  Dir.glob(File.join('tmp','pids','*.spc')) do |fn|
    fc = Marshal.load(File.binread(fn))
    next if fc[:pid] == pid
    next if File.exists?(File.join('','proc',String(fc[:pid])))
    next if is_valid.call(fc[:pid])
    File.unlink(fn)
  end
  # puts "#{$0} #{ARGV} #{cmdline}"
}.call
