###################################################################################################
# MIXINS
###################################################################################################

class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def yellow;         brown.bold           end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

class TrueClass
  def greenred;       "Yes".green end
  def redgreen;       "Yes".red end
end

class FalseClass
  def greenred;       "No".red end
  def redgreen;       "No".green end
end

class Object
  # pretty print w/o output
  def ppp o
    puts o.pretty_inspect
  end

  def p
    pp self
    nil
  end
end


###################################################################################################
# DUMPS
###################################################################################################

# Dumps an array of data
# usage:   dump 'a b', [[1 2], [3 4]]
# usage:   dump "my~id line\nline -hide", [[1 2], [3 4]]      # spaces and newlines and hidden columns in header
#
def dump header_def, rows, title=nil, options={}
  fname = options[:fname]
  indent = options[:indent] || 0
  subrows = options[:subrows]
  jira  = options[:jira]
  start = options[:duration]
  start = Time.now if start == true

  puts "output to #{fname}" if fname
  $stdout = File.new(fname,'w') if fname

  return dumpjira(header_def, rows, title, indent, subrows) if jira

  raise "rows must be an array" unless rows.is_a? Array

  prefix = ' '*indent

  puts "\n#{prefix}#{title}  (#{rows&.count || 0} records)\n" if title

  return if rows.blank?

  header_def = header_def.split(/ /) if header_def.is_a? String
  visible_columns = header_def.each_index.select{|i| header_def[i][0] != '-'}
  header_def = header_def.values_at(*visible_columns)

  widths = header_def.map {|col| col.split.map{|ln|ln.length}.max}
  height = header_def.map {|col| col.split.length}.max
  headers = Array.new(height){Array.new(header_def.length)}
  header_def.each_with_index {|col,n| lnheight = col.split.length; col.split.each_with_index{|cell,m| headers[m+height-lnheight][n] = cell.gsub('~',' ')}}

  rows.each do |values|
    values.replace(values.values_at(*visible_columns))
    (0...widths.length).each do |n|
      v = values[n]
      width = v.to_s.length
      widths[n] = width if width > widths[n]
      values[n] = '-' unless v.present?
    end
  end

  format = widths.map{|w| "#{prefix}%-#{w}s"}.join('  ')
  headers.each {|h| puts format%h}
  puts format%widths.map {|w| '-'*w}
  format += "%s" if subrows
  rows.each do |values|
    puts (format%values)
    rescue ArgumentError => e
      raise e.exception "#{e.message} (#{values.count}/#{widths.count}): #{values.inspect}"
  end

  puts "\nDuration: #{Time.now - start} seconds" if start
  $stdout.close if fname
  $stdout = STDOUT if fname
  nil
end

def dumpjira header_def, rows, title=nil, indent=0, subrows = false

  raise "rows must be an array" unless rows.is_a? Array

  prefix = ' '*indent

  puts "\nh3. #{prefix}#{title}  (#{rows&.count || 0} records)\n" if title

  return if rows.blank?

  header_def = header_def.split(/ /) if header_def.is_a? String
  visible_columns = header_def.each_index.select{|i| header_def[i][0] != '-'}
  header_def = header_def.values_at(*visible_columns)

  widths = header_def.map {|col| col.split.map{|ln|ln.length}.max}
  height = header_def.map {|col| col.split.length}.max
  headers = Array.new(height){Array.new(header_def.length)}
  header_def.each_with_index {|col,n| lnheight = col.split.length; col.split.each_with_index{|cell,m| headers[m+height-lnheight][n] = cell.gsub('~',' ')}}

  rows.each do |values|
    values.replace(values.values_at(*visible_columns))
    (0...widths.length).each do |n|
      v = values[n]
      width = v.to_s.length
      widths[n] = width if width > widths[n]
      values[n] = '--' unless v.present?
    end
  end

  puts '|| ' + headers.join(' || ') + '||'
  format += "%s" if subrows
  rows.each do |values|
    puts '| ' + values.join(' | ') + ' |'
    rescue ArgumentError => e
      raise e.exception "#{e.message} (#{values.count}/#{widths.count}): #{values.inspect}"
  end
  nil
end

# Dumps an array of data to a file
def fdump header_def, rows, title=nil, indent=0, subrows = false
  f = File.open('../dumpf.txt', 'w')
  prefix = ' '*indent

  f.puts "\n#{prefix}#{title}  (#{rows&.count || 0} records)\n" if title

  return if rows.blank?

  header_def = header_def.split(/ /) if header_def.is_a? String
  widths = header_def.map {|col| col.split.map{|ln|ln.length}.max}
  height = header_def.map {|col| col.split.length}.max
  headers = Array.new(height){Array.new(header_def.length)}
  header_def.each_with_index {|col,n| lnheight = col.split.length; col.split.each_with_index{|cell,m| headers[m+height-lnheight][n] = cell.gsub('~',' ')}}

  rows.each do |values|
    (0...widths.length).each do |n|
      v = values[n]
      width = v.to_s.length
      widths[n] = width if width > widths[n]
      values[n] = '-' unless v.present?
    end
  end

  format = widths.map{|w| "#{prefix}%-#{w}s"}.join('  ')
  headers.each {|h| f.puts format%h}
  f.puts format%widths.map {|w| '-'*w}
  format += "%s" if subrows
  rows.each do |values|
    f.puts (format%values)
    rescue ArgumentError => e
      raise e.exception "#{e.message} (#{values.count}/#{widths.count}): #{values.inspect}"
  end
  nil
end

# Dump associative array
def dumpa data, title=nil, options={}
  if data.is_a?(Array) || data.is_a?(ActiveRecord::Relation)
    data.each{|row| dumpa row, title, options}
    return nil
  end

  if data.is_a?(ActiveRecord::Base)
    title = data.class.to_s if title.nil?
    data = data.attributes
  end

  renderer = (options[:jira] ? DumpRendererJira : DumpRendererConsole).new(data)

  renderer.title title
  data.each do |key, value|
    renderer.kv key, value
  end
end

class DumpRendererConsole
  def initialize data
    @maxkeylen = data.reduce(0) {|a, (key, value)| key.length > a ? key.length : a}
  end

  def title title
    puts title.yellow.bold if title
  end

  def kv key, value
    puts "    %-#{@maxkeylen}s  %-40s\n"%[key, value]
  end
end

class DumpRendererJira
  def initialize data=nil
  end

  def title title
    puts "h3. #{title}" if title
    puts "||Key||Value||"
  end

  def kv key, value
    value = ' ' if value.blank?
    puts "|#{key}|#{value}|"
  end
end
