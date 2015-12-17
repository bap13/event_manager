require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

puts "Event Manager initialized."

contents = CSV.open 'event_attendees.csv', headers: true,
                                           header_converters: :symbol
template_letter = File.read 'form_letter.erb'
erb_template = ERB.new template_letter

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
  digits = phone_number.scan(/\d+/).join
  if digits.length == 10
    digits
  elsif digits.length == 11 && digits[0] == "1"
    digits[1..-1]
  else
    nil
  end
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_letter(id, letter)
  Dir.mkdir("output") unless Dir.exists? "output"
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts letter
  end
end

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  personal_letter = erb_template.result(binding)
  save_letter(id, personal_letter)
end
