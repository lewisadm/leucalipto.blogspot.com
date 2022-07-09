import re
import requests
from bs4 import BeautifulSoup
import sys

### questo script serve a controllare se una data pagina web è indicizzata in google

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


url = sys.argv[1]

google = "https://www.google.com/search?q=site:" + url + "&hl=en"
response = requests.get(google, cookies={"CONSENT": "YES+1"})
soup = BeautifulSoup(response.content, "html.parser")
not_indexed = re.compile("did not match any documents")

if soup(text=not_indexed):
  print(bcolors.FAIL+" KO "+bcolors.ENDC)
else:
  print(bcolors.OKGREEN+" OK "+bcolors.ENDC)


