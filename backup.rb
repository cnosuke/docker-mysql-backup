#!/usr/local/bin/ruby

DATABASES = ENV['DB']&.split(',')
DB_HOST   = ENV['DB_HOST'] || 'db'
DB_USER   = ENV['DB_USER'] || 'root'
DB_PW     = ENV['DB_PASSWORD']
DIST      = ENV['DIST'] || '/tmp/backups/'
LZ4_DIST  = ENV['LZ4_DIST']

if [DATABASES, DB_HOST, DB_USER, DB_PW].any?(&:nil?)
  raise ArgumentError
end

def backup_database(db_name)
  cmd = "mysqldump -u#{DB_USER} -p#{DB_PW} -h#{DB_HOST} #{db_name} > #{DIST}#{db_name}.dump.sql"

  system(cmd)
end

def compress(db_name)
  in_fname  = "#{DIST}#{db_name}.dump.sql"
  out_fname = "#{LZ4_DIST}#{db_name}.dump.sql.lz4"
  cmd = "lz4 #{in_fname} #{out_fname}"

  sytem(cmd)
end

DATABASES.each do |d|
  puts "Backup #{d} ..."
  backup_database(d)
  if LZ4_DIST
    puts "\tcompress to #{LZ4_DIST}#{db_name}.dump.sql.lz4"
    compress(d)
  end
end

puts "Done!"
