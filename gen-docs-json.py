#!/usr/bin/env python3

import yaml
import json
import os

from markdown import Markdown
from io import StringIO


def unmark_element(element, stream=None):
    if stream is None:
        stream = StringIO()
    if element.text:
        stream.write(element.text)
    for sub in element:
        unmark_element(sub, stream)
    if element.tail:
        stream.write(element.tail)
    return stream.getvalue()


Markdown.output_formats["plain"] = unmark_element
plain_md = Markdown(output_format="plain")
plain_md.stripTopLevelTags = False

docs = []
baseDir = ""

def walkNavs(navs):
  for item in navs: 
    for k, v in item.items():
      if isinstance(v, (list, tuple)):
        walkNavs(v)
      elif v.endswith(".md"):
        md = open(os.path.join(baseDir, v)).read()
        docs.append({
          "path": v,
          "title": k,
          "body": plain_md.convert(md)
        })

mkdocsData = open("mkdocs.yml").read()
mkdocs = yaml.load(mkdocsData, Loader=yaml.SafeLoader)
baseDir = mkdocs["docs_dir"]
walkNavs(mkdocs["nav"])
print(json.dumps(docs))

