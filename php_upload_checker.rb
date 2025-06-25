require 'watir'

php_file_path = File.expand_path("test.php", __dir__)
@browser = Watir::Browser.new(:chrome, headless: true)

puts " Starting PHP upload checks..."
selected_site = "primebids"
sites = [
  {
    site: "https://ledmaxb2b-test.ecommerce.auction",
    login_url: "https://ledmaxb2b-test.ecommerce.auction/login",
    email: "ramya@auctionsoftware",
    password: "pass123",
    upload_url: "https://ledmaxb2b-test.ecommerce.auction/profile",
    upload_selector: { type: :div, class: /dropzone/ },
    key: "ledmaxb2b"
  },
  {
    site: "https://shipcycleauction-test.ecommerce.auction",
    login_url: "https://shipcycleauction-test.ecommerce.auction/signin",
    email: "ramya@auctionsoftware.com",
    password: "123456",
    upload_url: "https://shipcycleauction-test.ecommerce.auction/profile",
    upload_selector: { type: :input, file: true },
    key: "shipcycle"
  }
  {
    site: "https://auction_preview.ecommerce.auction/337",
    login_url: "https://auction_preview.ecommerce.auction/337/login",
    email: "ramya.karthikeyan+prime@auctionsoftware.com",
    password: "Ramskaerthy@123",
    upload_url: "https://auction_preview.ecommerce.auction/337/dashboard/profile",
    upload_selector: { type: :input, file: true },
    key: "primebids"
  }
]


def find_file_input(browser, selector)
  return browser.file_field(visible: false) if selector[:type] == :input && selector[:file]

  if selector[:type] == :div && selector[:class]
    div = browser.div(class: selector[:class])
    return div.file_field(visible: false) if div.exists?
  end

  nil
end

# Main loop through sites
filtered_sites = sites.select { |s| s[:key] == selected_site }
filtered_sites.each do |site_info|
  puts "\n Testing site: #{site_info[:site]}"
  begin

    @browser.goto(site_info[:login_url])
    @browser.text_field(name: /email|username/).wait_until(&:present?).set(site_info[:email])
    @browser.text_field(type: 'password').set(site_info[:password])

    if @browser.button(type: 'submit').exists?
      @browser.button(type: 'submit').click
    else
      @browser.button.click
    end

    sleep 2

   
    @browser.goto(site_info[:upload_url])
    sleep 1

   
    file_input = find_file_input(@browser, site_info[:upload_selector])
    unless file_input&.exists?
      puts " File input not found using selector: #{site_info[:upload_selector].inspect}"
      next
    end

    puts " File input found. Accepts: #{file_input.attribute_value('accept')}"
    file_input.set(php_file_path)

 
    if @browser.button(type: 'submit').exists?
      @browser.button(type: 'submit').click
    elsif @browser.button.exists?
      @browser.button.click
    elsif @browser.form.exists?
      @browser.form.submit
    else
      puts " No submit button or form found."
      next
    end

    sleep 2

  
    if @browser.text.match?(/not allowed|invalid|forbidden|file type|error/i)
      puts " Upload blocked successfully."
    else
      puts " WARNING: PHP file might have been accepted!"
    end

  rescue => e
    puts " Error: #{e.message}"
  end
end

@browser.close
puts "\n All sites checked."
