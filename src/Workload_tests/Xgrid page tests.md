# XGRID SITE PAGE TESTS

This is a Python script that tests the web pages of the XGRID site. The script uses the Selenium library and the Chrome web driver to open the web pages and check if they are working as expected.

## Requirements

- Python 3
- Selenium library
- Chrome web driver

## Usage

The script can be run by executing the `xgrid_page_test()` function. This function calls the `xgrid_page(page_url)` function for each URL in the `config.XGRID_URLS` list. 
The `xgrid_page(page_url)` function opens the specified URL using the Chrome web driver and catches any exceptions that may occur during the process.
In case of a failure, an error message is displayed indicating the failed URL and the error that occurred.

## Configuration

The URLs to be tested are specified in the `config.XGRID_URLS` list. This list can be modified to include or remove URLs as needed.

## Conclusion

This script can be used to automate the testing of the XGRID site pages, ensuring that they are working as expected and reducing the manual effort required to test each page. The script can be easily modified to include additional tests or to use a different web driver.
