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

def walkNavs(navs, parent):
  for item in navs: 
    for k, v in item.items():
      menu = {
        "title": k
      }

      if isinstance(v, (list, tuple)):
        menu["type"] = "catalog"
        menu["path"] = os.path.join(rootDir, parent.get("title"), k)
        menu["children"] = []
        walkNavs(v, menu)
      elif v.endswith(".md"):
        menu["type"] = "file"
        menu["path"] = os.path.join(rootDir, v)
      else:
        menu["type"] = "link"
        menu["path"] = v

      parent["children"].append(menu)

mkdocsData = open("mkdocs.yml").read()
mkdocs = yaml.load(mkdocsData, Loader=yaml.SafeLoader)
currDir = os.path.basename(os.getcwd())
rootDir = os.path.join(currDir, mkdocs["docs_dir"])
rootTitle = mkdocs["site_name"]
root = {
  "title": rootTitle,
  "path": rootDir,
  "children": []
}
walkNavs(mkdocs["nav"], root)

print(json.dumps(root))
