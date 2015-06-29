# -*- coding: utf-8 -*-
from newspaper import Article
from goose import Goose
import json
import sys

article = Article(sys.argv[1])

article.download()
article.parse()
article.nlp()

published = ''
if article.publish_date:
  published = article.publish_date.strftime("%Y-%m-%d %H:%M:%S")

# Get body with goose
g = Goose()
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
