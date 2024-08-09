Capybara.default_driver    = :selenium_chrome
Capybara.javascript_driver = :selenium_chrome

Capybara.register_driver :selenium_chrome do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_preference(:download, default_directory: DownloadHelpers::PATH.to_s)
  options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

module DownloadHelpers
  TIMEOUT = 1
  PATH    = Rails.root.join('tmp')

  def clear_downloads
    downloads = PATH.join('rec.webm')
    FileUtils.rm_f(downloads)
  end
end
