from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
import config
import time

# Create an instance of the Chrome driver
options = webdriver.ChromeOptions()
options.add_argument("--start-fullscreen")

driver = webdriver.Chrome(options=options)

# Navigate to the website home page
home = driver.get(config.home_page)

# Navigate to xgrid career's page
career = driver.get(config.career_page)

# Navigate to xgrid DevOps page using click
devops_link = driver.find_element(By.XPATH,config.devops_page).click()

try:
    WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH,config.devops_XPATH)))
except Exception as e:
    print("Error:", str(e))

# Navigate to xgrid web and mobile page
web_and_mobile = driver.find_element(By.XPATH,config.web_and_mobile_path_XPATH).click()

# Navigate to xgrid company's page
company = driver.get(config.company_path)

# navigate to Xgrid resources page.
resources = driver.get(config.resources_path)

# Navigate to xgrid blogs and then opens up TLS blog
blog = driver.get(config.blog_path)

# Navigate to xgrid information and security page
information_security_policy = driver.get(config.information_security_policy_path)

# Navigate to xgrid open positions page
open_positions = driver.get(config.open_positions_path)

# Navigate to xgrid privacy policy page
privacy_policy = driver.get(config.privacy_policy_path)

# Navigate to xgrid terms and conditions page
terms_and_conditions = driver.get(config.terms_and_conditions_path)

# Navigate to xgrid thankyou page
thankyou = driver.get(config.thankyou_path)

# Close the browser
driver.quit()
