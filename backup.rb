#!/usr/local/bin/ruby

DATABASES = ENV['DB']&.split(',')
DB_HOST   = ENV['DB_HOST'] || 'db'
DB_USER   = ENV['DB_USER'] || 'root'
DB_PW     = ENV['DB_PASSWORD']
DIST      = ENV['DIST'] || '/tmp/backups/'
LZ4_DIST  = ENV['LZ4_DIST'] || nil
STRFTIME  = ENV['STRFTIME'] || nil
NOW = Time.now

if [DATABASES, DB_HOST, DB_USER, DB_PW].any?(&:nil?)
  raise ArgumentError
end

def fname(dist, db_name, postfix = nil)
  dist = dist.end_with?('/') ? dist : "#{dist}/"
  time = STRFTIME ? "_"+NOW.strftime(STRFTIME) : nil

  [dist, db_name, time, ".dump", ".sql", postfix].compact.join
end

def backup_database(db_name)
  cmd = "mysqldump -u#{DB_USER} -p#{DB_PW} -h#{DB_HOST} #{db_name} > #{fname(DIST, db_name)}"

  system(cmd)
end

def compress(db_name)
  in_fname  = fname(DIST, db_name)
  out_fname = fname(LZ4_DIST, db_name, '.lz4')
  cmd = "lz4 #{in_fname} #{out_fname}"

  system(cmd)
end

DATABASES.each do |d|
  puts "Backup #{d} ..."
  backup_database(d)
  if LZ4_DIST
    puts "\tcompress to #{fname(LZ4_DIST, d, '.lz4')}"
    compress(d)
  end
end

puts "Done!"
