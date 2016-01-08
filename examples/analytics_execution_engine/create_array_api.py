# ------------------------------------------------------------------------------
# Name:       create_array_api.py
# Purpose:    create array example for Analytics Engine & Execution Engine.
#             pre-integration with NDExpr.
#             post-integration with Data Access API.
#             Taken from the GDF Trial.
#
# Author:     Peter Wang
#
# Created:    22 December 2015
# Copyright:  2015 Commonwealth Scientific and Industrial Research Organisation
#             (CSIRO)
# License:    This software is open source under the Apache v2.0 License
#             as provided in the accompanying LICENSE file or available from
#             https://github.com/data-cube/agdc-v2/blob/master/LICENSE
#             By continuing, you acknowledge that you have read and you accept
#             and will abide by the terms of the License.
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import
from __future__ import print_function

if __name__ == '__main__' and __package__ is None:
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.dirname(path.abspath(__file__)))))

from pprint import pprint
from datetime import datetime
from datacube.analytics.analytics_engine import AnalyticsEngine
from datacube.execution.execution_engine import ExecutionEngine
from datacube.analytics.utils.analytics_utils import plot


def main():
    a = AnalyticsEngine()
    e = ExecutionEngine()

    dimensions = {'longitude': {'range': (150, 150.256)}, 'latitude': {'range': (-34.0, -33.744)}}

    arrays = a.createArray(('LANDSAT_5', 'EODS_NBAR'), ['band_30', 'band_40'], dimensions, 'get_data')

    e.executePlan(a.plan)

    plot(e.cache['get_data'])

if __name__ == '__main__':
    main()
