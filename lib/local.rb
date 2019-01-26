#!/usr/bin/env ruby

# EXECUTING LOCAL DATA IN .local
fn = File.join(Rails.root, '.local_script')
if File.exists?(fn) then
  begin
    eval File.read(fn), binding, fn
  rescue => e
    $stderr.puts "#{e.class}: #{e.message}"
    $stderr.puts e.backtrace
  end
end

