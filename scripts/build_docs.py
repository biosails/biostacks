#!/usr/bin/env python

from conda_build.config import Config
from conda_build.metadata import MetaData
from conda_build.render import render_recipe

recipe_dir = 'recipes/gencore_rnaseq/1.0/meta.yaml'

config =  Config(croot=recipe_dir, anaconda_upload=False, verbose=True,
activate=False, debug=False, variant=None)
metadata = render_recipe(recipe_dir, config=config)
