require 'capybara'
require 'selenium-webdriver'

Capybara.default_driver = :selenium
Capybara.app_host = 'https://sleeper.com'

SLEEPER_USERNAME = 'your_sleeper_username'
SLEEPER_PASSWORD = 'your_sleeper_password'
SLEEPER_PLAYERS = 'https://sleeper.com/leagues/YOUR_LEAGUE_ID/waivers'  # Replace with your actual waiver page URL

# Function to login to Sleeper
def login_sleeper(username, password)
  visit '/login'  # Visit the Sleeper login page

  # Find and fill in the login form
  find('input[type="email"]').set(username)
  find('input[type="password"]').set(password)

  # Click the login button
  click_button('Log In')

  # Wait for the login to complete (adjust this condition based on what loads after login)
  page.should_not have_css('.loading-indicator')
end

# Function to add a free agent and drop a player
def add_drop(free_agent, droppable)
  # Search for the free agent
  find('input[placeholder="Search"]').set(free_agent)
  sleep 2  # Give time for search results to populate
  if page.has_css?('.waiver-player', text: free_agent)
    find('.waiver-player', text: free_agent).click
    sleep 1

    if page.has_button?('Claim') # Sleeper uses 'Claim' for adding players
      click_button('Claim')

      # Select player to drop
      find('.player-drop-checkbox', text: droppable).click

      # Submit the waiver claim
      click_button('Submit Waiver Claim')
      puts "Submitted waiver claim to add #{free_agent} and drop #{droppable}"
    else
      puts "Sorry, #{free_agent} is not available or already claimed."
    end
  else
    puts "Could not find #{free_agent} in waivers."
  end
end

# RSpec Feature to Test Adding and Dropping Players in Sleeper League
feature "Manage Fantasy Football Team on Sleeper" do

  background do
    visit SLEEPER_PLAYERS  # Go to the Sleeper waiver page
    login_sleeper(SLEEPER_USERNAME, SLEEPER_PASSWORD)  # Log in
  end

  after(:each) do
    Capybara.current_session.driver.quit
  end

  scenario "Add and drop a player" do
    add_drop('Joe Flacco', 'Deshaun Watson')  # Replace with your desired players
  end

  scenario "Add and drop another player" do
    add_drop('Leonard Fournette', 'Alex Collins')  # Replace with your desired players
  end
end
