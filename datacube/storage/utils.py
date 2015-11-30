# coding=utf-8
"""
Utility functions used in storage access
"""
from __future__ import absolute_import, division, print_function

import logging
from pathlib import Path

from datacube.model import TileSpec

_LOG = logging.getLogger(__name__)


def namedtuples2dicts(namedtuples):
    """
    Convert a dict of namedtuples to a dict of dicts

    :param namedtuples: dict of namedtuples
    :return: dict of dicts
    """
    return {k: dict(vars(v)) for k, v in namedtuples.items()}


def tilespec_from_riodataset(rio, global_attrs=None):
    projection = rio.crs_wkt
    width, height = rio.width, rio.height
    return TileSpec(height, width, projection, rio.affine, rio.bounds, global_attrs)


def ensure_path_exists(filename):
    file_dir = Path(filename).parent
    if not file_dir.exists:
        file_dir.parent.mkdir(parents=True)
