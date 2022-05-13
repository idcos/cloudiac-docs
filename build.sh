#!/bin/bash

( cd docs && ../gen-catalog-json.py > catalog.json && ../gen-docs-json.py > docs.json )
( cd tutorials && ../gen-catalog-json.py > catalog.json && ../gen-docs-json.py > docs.json )

