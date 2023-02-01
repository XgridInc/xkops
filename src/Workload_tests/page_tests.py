""" XGRID WEBSITE PAGE TESTS """
import config
import selenium
from selenium import webdriver
from selenium.webdriver.support import expected_conditions as EC

# Create an instance of the Chrome driver
options = webdriver.ChromeOptions()
options.add_argument("--start-fullscreen")
driver = webdriver.Chrome(options=options)

def xgrid_page(page_url):
    """functions to call the URLs of the webpages of website."""
    try:
        driver.get(page_url)
    except selenium.common.exceptions.WebDriverException as e:
        print(f"Failed to load the homepage: {e}")
    except Exception as e:
        print("An unknown error occured:", e)


def xgrid_page_test():
    """functions to tests the webpages of website."""    
    for url in config.XGRID_URLS:
        xgrid_page(url)


# xgrid pages test function call
xgrid_page_test()
# Close the browser
driver.quit()
