# -*- coding: utf-8 -*-
from newspaper import Article
from goose3 import Goose
import requests
import json
import sys
import urllib3
urllib3.disable_warnings()

ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36'

article = Article(sys.argv[1])

s = requests.Session()
r = s.get(sys.argv[1], verify=False, headers={'User-Agent': ua}, allow_redirects=True)
article.set_html(r.text)

article.parse()
article.nlp()

published = ''
if article.publish_date:
    published = article.publish_date.strftime("%Y-%m-%d %H:%M:%S")

# Get body with goose
g = Goose({'browser_user_agent': ua})
goose_article = g.extract(raw_html=article.html)
body = goose_article.cleaned_text
summary = goose_article.meta_description

# Maybe use https://github.com/xiaoxu193/PyTeaser
if not summary:
    summary = article.summary

if not body or len(body) < len(article.text):
    body = article.text

json_str = json.dumps({
    'author': ", ".join(article.authors),
    'image': article.top_image,
    'keywords': article.keywords,
    'published': published,
    'summary': summary,
    'body': body,
    'title': article.title,
    'videos': article.movies
}, sort_keys=True, ensure_ascii=False)

print(json_str)
