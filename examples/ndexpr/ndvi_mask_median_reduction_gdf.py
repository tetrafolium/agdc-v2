# ------------------------------------------------------------------------------
# Name:       ndvi_mask_median_reduction_gdf.py
# Purpose:    ndvi + mask + median reduction example for ndexpr
#             pre-integration into Analytics Engine & Execution Engine.
#             pre-integration with Data Access API.
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

if __name__ == '__main__' and __package__ is None:
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.dirname(path.abspath(__file__)))))

import xray
from datacube.gdf import GDF
from datacube.ndexpr import NDexpr


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
    b30 = d1['arrays']['B30']
    b40 = d1['arrays']['B40']
    pq = nd.get_pqa_mask(d2['arrays']['PQ'].values)

    print('NDexpr demo begins here')
    # ndvi + mask + median reduction example as expressed in this language.
    ndvi = nd.evaluate('((b40 - b30) / (b40 + b30))')
    masked_ndvi = nd.evaluate('ndvi{pq}')

    # currently dimensions are integer indices, later will be labels when
    # Data Access API Interface has been finalised.
    reduction_on_dim0 = nd.evaluate('median(masked_ndvi, 0)')
    reduction_on_dim01 = nd.evaluate('median(masked_ndvi, 0, 1)')
    reduction_on_dim012 = nd.evaluate('median(masked_ndvi, 0, 1, 2)')
    print(reduction_on_dim0)
    print(reduction_on_dim01)
    print(reduction_on_dim012)

if __name__ == '__main__':
    main()
