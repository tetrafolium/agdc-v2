# ------------------------------------------------------------------------------
# Name:       ndvi.py
# Purpose:    ndvi example for ndexpr
#             pre-integration into Analytics Engine & Execution Engine.
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
import xray
sys.path.append(os.path.dirname(os.path.dirname(os.getcwd())))
from gdf import GDF
from ndexpr import NDexpr


def main():
    print('Instantiating GDF and NDexpr')
    g = GDF()
    nd = NDexpr()

    print('Retrieving data from GDF')
    # construct data request parameters for B30 and B40
    data_request_descriptor = {'storage_type': 'LS5TM',
                               'variables': ('B30', 'B40'),
                               'dimensions': {'X': {'range': (147.0, 147.256)},
                                              'Y': {'range': (-37.0, -36.744)}
                                              }
                               }

    # get data
    d1 = g.get_data(data_request_descriptor)

    # construct data request parameters for PQ
    pq_request_descriptor = {'storage_type': 'LS5TMPQ',
                             'variables': ['PQ'],
                             'dimensions': {'X': {'range': (147.0, 147.256)},
                                            'Y': {'range': (-37.0, -36.744)}
                                            }
                             }

    # get data
    d2 = g.get_data(pq_request_descriptor)

    # The following 3 lines shouldn't be done like this
    # Currently done like this for the sake of the example.
    b30 = xray.DataArray(d1['arrays']['B30'])
    b40 = xray.DataArray(d1['arrays']['B40'])
    pq = xray.DataArray(nd.get_pqa_mask(d2['arrays']['PQ']))

    print('NDexpr demo begins here')
    # perform ndvi as expressed in this language.
    ndvi = nd.evaluate('((b40 - b30) / (b40 + b30))')
    # perform mask on ndvi as expressed in this language.
    masked_ndvi = nd.evaluate('ndvi{pq}')
    print(masked_ndvi)

if __name__ == '__main__':
    main()
