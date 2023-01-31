""" XGRID WEBSITE PAGE TESTS """
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import config

# Create an instance of the Chrome driver
options = webdriver.ChromeOptions()
options.add_argument("--start-fullscreen")

driver = webdriver.Chrome(options=options)

# Navigate to the website home page
driver.get(config.HOME_PAGE)

# Navigate to xgrid career's page
driver.get(config.CAREER_PAGE)

# Navigate to xgrid DevOps page using click
driver.find_element(By.XPATH,config.DEVOPS_PAGE).click()
WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH,config.DEVOPS_XPATH)))


# Navigate to xgrid web and mobile page
driver.find_element(By.XPATH,config.WAM_XPATH).click()

# Navigate to xgrid company's page
driver.get(config.COMPANY_PATH)

# navigate to Xgrid resources page.
driver.get(config.RESOURCES_PATH)

# Navigate to xgrid blogs and then opens up TLS blog
driver.get(config.BLOG_PATH)

# Navigate to xgrid information and security page
driver.get(config.ISP_PATH)

# Navigate to xgrid open positions page
driver.get(config.OPEN_POSITIONS_PATH)

# Navigate to xgrid privacy policy page
driver.get(config.PRIVACY_POLICY_PATH)

# Navigate to xgrid terms and conditions page
driver.get(config.TAC_PATH)

# Navigate to xgrid thankyou page
driver.get(config.THANKYOU_PATH)

# Close the browser
driver.quit()
