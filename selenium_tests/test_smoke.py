
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait


def test_studyflow_opens_in_chrome():
    driver = webdriver.Chrome()

    try:
        driver.get("http://localhost:5000")

        wait = WebDriverWait(driver, 15)

        wait.until(
            lambda d: "StudyFlow" in d.page_source
        )

        assert "StudyFlow" in driver.page_source

    finally:
        driver.quit()
