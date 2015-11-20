# ------------------------------------------------------------------------------
# Name:       chain_ndvi_median.py
# Purpose:    chain_ndvi_median example for Analytics Engine & Execution Engine.
#             pre-integration with NDExpr.
#             Taken from the GDF Trial.
#
# Author:     Peter Wang
#
# Created:    20 November 2015
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
import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.getcwd())))
from pprint import pprint
from datetime import datetime
from analytics import Analytics
from execution_engine import ExecutionEngine
from analytics_utils import plot

def main():
    a = Analytics()
    e = ExecutionEngine()

    dimensions = {'X': {'range': (147.0, 147.256)},
                  'Y': {'range': (-37.0, -36.744)}}

    arrays = a.createArray('LS5TM', ['B40', 'B30'], dimensions, 'get_data')
    ndvi = a.applyBandMath(arrays, '((array1 - array2) / (array1 + array2))', 'ndvi')
    arrays2 = a.createArray('LS5TM', ['B40', 'B30'], dimensions, 'get_data2')
    ndvi2 = a.applyBandMath(arrays2, '((array1 - array2) / (array1 + array2))', 'ndvi2')
    average = a.applyBandMath([ndvi, ndvi2], '((array1 + array2) / 2)', 'average')
    pq_data = a.createArray('LS5TMPQ', ['PQ'], dimensions, 'pq_data')
    mask = a.applyCloudMask(average, pq_data, 'mask')
    median_t = a.applyGenericReduction(mask, ['T'], 'median(array1)', 'medianT')
    result = e.executePlan(a.plan)

    plot(e.cache['medianT'])


if __name__ == '__main__':
    main()
