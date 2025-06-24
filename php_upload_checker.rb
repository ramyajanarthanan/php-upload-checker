require 'watir'
require 'csv'

php_file_path = File.expand_path("test.php", __dir__)
csv_file = File.expand_path("sites.csv", __dir__)
browser = Watir::Browser.new(:chrome, headless: true)

puts " Starting PHP upload check...\n"

CSV.foreach(csv_file, headers: true) do |row|
  site_url = row['url']
  puts "\n Testing site: #{site_url}"

  begin
    browser.goto(site_url)

    file_input = browser.file_field
    unless file_input.exists?
      puts "  No file input field found."
      next
    end

    file_input.set(php_file_path)

    # Try to submit the form
    if browser.button(type: 'submit').exists?
      browser.button(type: 'submit').click
    elsif browser.button.exists?
      browser.button.click
    elsif browser.form.exists?
      browser.form.submit
    else
      puts "No submit button or form found."
      next
    end

    sleep 2

    if browser.text.match?(/(not allowed|invalid|forbidden|file type)/i)
      puts "Upload blocked properly."
    else
      puts "WARNING: PHP file might have been accepted!"
    end

  rescue => e
    puts "Error: #{e.message}"
  end
end

browser.close
puts "\n All sites checked."
