# ------------------------------------------------------------------------------
# Name:       median_t_expression_gdf.py
# Purpose:    median reduction example for Analytics Engine & Execution Engine.
#             post-integration with NDExpr.
#             pre-integration with Data Access API.
#
# Author:     Peter Wang
#
# Created:    7 December 2015
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
    a = AnalyticsEngine(gdf=True)
    e = ExecutionEngine(gdf=True)

    dimensions = {'X': {'range': (147.0, 147.256)},
                  'Y': {'range': (-37.0, -36.744)}}

    arrays = a.createArray('LS5TM', ['B40'], dimensions, 'arrays')
    median = a.applyExpression(arrays, 'median(array1, 0)', 'medianT')
    pprint(median)

    e.executePlan(a.plan)

    plot(e.cache['medianT'])

if __name__ == '__main__':
    main()
