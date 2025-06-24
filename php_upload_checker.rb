require 'watir'

php_file_path = File.expand_path("test.php", __dir__)
@browser = Watir::Browser.new(:chrome, headless: true)

puts " Starting PHP upload checks..."

# Define site login/upload info in an array
sites = [
  {
    site: "https://ledmaxb2b-test.ecommerce.auction",
    login_url: "https://ledmaxb2b-test.ecommerce.auction/login",
    email: "ramya@auctionsoftware",
    password: "pass123",
    upload_url: "https://ledmaxb2b-test.ecommerce.auction/profile"
  },
  {
    site: "https://shipcycleauction-test.ecommerce.auction",
    login_url: "https://shipcycleauction-test.ecommerce.auction/signin",
    email: "ramya@auctionsoftware.com",
    password: "123456",
    upload_url: "https://shipcycleauction-test.ecommerce.auction/profile"
  }
]

sites.each do |site_info|
  puts "\nTesting site: \#{site_info[:site]}"
  begin
    # Step 1: Login
    @browser.goto(site_info[:login_url])

    @browser.text_field(name: /email|username/).set(site_info[:email])
    @browser.text_field(type: 'password').set(site_info[:password])

    if @browser.button(type: 'submit').exists?
      @browser.button(type: 'submit').click
    elsif @browser.button.exists?
      @browser.button.click
    else
      puts " Login button not found."
      next
    end

    sleep 2

    # Step 2: Navigate to upload page
    @browser.goto(site_info[:upload_url])

    file_input = @browser.file_field
    unless file_input.exists?
      puts " No file input field found."
      next
    end

    file_input.set(php_file_path)

    # Step 3: Submit upload
    if @browser.button(type: 'submit').exists?
      @browser.button(type: 'submit').click
    elsif @browser.button.exists?
      @browser.button.click
    elsif @browser.form.exists?
      @browser.form.submit
    else
      puts "No submit button or form found."
      next
    end

    sleep 2

    if @browser.text.match?(/(not allowed|invalid|forbidden|file type)/i)
      puts "Upload blocked properly."
    else
      puts "WARNING: PHP file might have been accepted!"
    end

  rescue => e
    puts " Error: \#{e.message}"
  end
end

@browser.close
puts "\n All sites checked."
