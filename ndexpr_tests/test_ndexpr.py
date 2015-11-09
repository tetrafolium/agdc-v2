from __future__ import absolute_import
import unittest
import os
from ndexpr import NDexpr
import xray
import numpy as np

import sys
from gdf import GDF

#
# Test cases for NDexpr class
#

# pylint: disable=too-many-public-methods
#
# Disabled to avoid complaints about the unittest.TestCase class.
#


class TestNDexpr(unittest.TestCase):
    """Unit tests for utility functions."""

    def test_1(self):
        test_ndexpr = NDexpr()

    def test_2(self):
        # perform language test
        
        ne = NDexpr()
        x1 = xray.DataArray(np.random.randn(2, 3))
        y1 = xray.DataArray(np.random.randn(2, 3))
        z1 = xray.DataArray(np.array([[[0,  1,  2], [3,  4,  5], [6,  7,  8]],
                                     [[9, 10, 11], [12, 13, 14], [15, 16, 17]],
                                     [[18, 19, 20], [21, 22, 23], [24, 25, 26]]
                                      ]))
        z2 = z1*2
        z3 = np.arange(27)
        mask1 = z1 > 4

        assert(ne.test("arccos(z1)", xray.ufuncs.arccos(z1)))
        assert(ne.test("angle(z1)", xray.ufuncs.angle(z1)))
        assert(ne.test("arccos(z1)", xray.ufuncs.arccos(z1)))
        assert(ne.test("arccosh(z1)", xray.ufuncs.arccosh(z1)))
        assert(ne.test("arcsin(z1)", xray.ufuncs.arcsin(z1)))
        assert(ne.test("arcsinh(z1)", xray.ufuncs.arcsinh(z1)))
        assert(ne.test("arctan(z1)", xray.ufuncs.arctan(z1)))
        assert(ne.test("arctanh(z1)", xray.ufuncs.arctanh(z1)))
        assert(ne.test("ceil(z1)", xray.ufuncs.ceil(z1)))
        assert(ne.test("conj(z1)", xray.ufuncs.conj(z1)))
        assert(ne.test("cos(z1)", xray.ufuncs.cos(z1)))
        assert(ne.test("cosh(z1)", xray.ufuncs.cosh(z1)))
        assert(ne.test("deg2rad(z1)", xray.ufuncs.deg2rad(z1)))
        assert(ne.test("degrees(z1)", xray.ufuncs.degrees(z1)))
        assert(ne.test("exp(z1)", xray.ufuncs.exp(z1)))
        assert(ne.test("expm1(z1)", xray.ufuncs.expm1(z1)))
        assert(ne.test("fabs(z1)", xray.ufuncs.fabs(z1)))
        assert(ne.test("fix(z1)", xray.ufuncs.fix(z1)))
        assert(ne.test("floor(z1)", xray.ufuncs.floor(z1)))
        assert(ne.test("frexp(z3)", xray.DataArray(xray.ufuncs.frexp(z3))))
        assert(ne.test("imag(z1)", xray.ufuncs.imag(z1)))
        assert(ne.test("iscomplex(z1)", xray.ufuncs.iscomplex(z1)))
        assert(ne.test("isfinite(z1)", xray.ufuncs.isfinite(z1)))
        assert(ne.test("isinf(z1)", xray.ufuncs.isinf(z1)))
        assert(ne.test("isnan(z1)", xray.ufuncs.isnan(z1)))
        assert(ne.test("isreal(z1)", xray.ufuncs.isreal(z1)))
        assert(ne.test("log(z1)", xray.ufuncs.log(z1)))
        assert(ne.test("log10(z1)", xray.ufuncs.log10(z1)))
        assert(ne.test("log1p(z1)", xray.ufuncs.log1p(z1)))
        assert(ne.test("log2(z1)", xray.ufuncs.log2(z1)))
        assert(ne.test("rad2deg(z1)", xray.ufuncs.rad2deg(z1)))
        assert(ne.test("radians(z1)", xray.ufuncs.radians(z1)))
        assert(ne.test("real(z1)", xray.ufuncs.real(z1)))
        assert(ne.test("rint(z1)", xray.ufuncs.rint(z1)))
        assert(ne.test("sign(z1)", xray.ufuncs.sign(z1)))
        assert(ne.test("signbit(z1)", xray.ufuncs.signbit(z1)))
        assert(ne.test("sin(z1)", xray.ufuncs.sin(z1)))
        assert(ne.test("sinh(z1)", xray.ufuncs.sinh(z1)))
        assert(ne.test("sqrt(z1)", xray.ufuncs.sqrt(z1)))
        assert(ne.test("square(z1)", xray.ufuncs.square(z1)))
        assert(ne.test("tan(z1)", xray.ufuncs.tan(z1)))
        assert(ne.test("tanh(z1)", xray.ufuncs.tanh(z1)))
        assert(ne.test("trunc(z1)", xray.ufuncs.trunc(z1)))

        assert(ne.test("arctan2(z1, z2)", xray.ufuncs.arctan2(z1, z2)))
        assert(ne.test("copysign(z1, z2)", xray.ufuncs.copysign(z1, z2)))
        assert(ne.test("fmax(z1, z2)", xray.ufuncs.fmax(z1, z2)))
        assert(ne.test("fmin(z1, z2)", xray.ufuncs.fmin(z1, z2)))
        assert(ne.test("fmod(z1, z2)", xray.ufuncs.fmod(z1, z2)))
        assert(ne.test("hypot(z1, z2)", xray.ufuncs.hypot(z1, z2)))
        assert(ne.test("ldexp(z1, z2)", xray.DataArray(xray.ufuncs.ldexp(z1, z2))))
        assert(ne.test("logaddexp(z1, z2)", xray.ufuncs.logaddexp(z1, z2)))
        assert(ne.test("logaddexp2(z1, z2)", xray.ufuncs.logaddexp2(z1, z2)))
        assert(ne.test("logicaland(z1, z2)", xray.ufuncs.logical_and(z1, z2)))
        assert(ne.test("logicalnot(z1, z2)", xray.ufuncs.logical_not(z1, z2)))
        assert(ne.test("logicalor(z1, z2)", xray.ufuncs.logical_or(z1, z2)))
        assert(ne.test("logicalxor(z1, z2)", xray.ufuncs.logical_xor(z1, z2)))
        assert(ne.test("maximum(z1, z2)", xray.ufuncs.maximum(z1, z2)))
        assert(ne.test("minimum(z1, z2)", xray.ufuncs.minimum(z1, z2)))
        assert(ne.test("nextafter(z1, z2)", xray.ufuncs.nextafter(z1, z2)))

        assert(ne.test("all(z1)", xray.DataArray.all(z1)))
        assert(ne.test("all(z1, 0)", xray.DataArray.all(z1, axis=0)))
        assert(ne.test("all(z1, 0, 1)", xray.DataArray.all(z1, axis=(0, 1))))
        assert(ne.test("all(z1, 0, 1, 2)", xray.DataArray.all(z1, axis=(0, 1, 2))))

        assert(ne.test("any(z1)", xray.DataArray.any(z1)))
        assert(ne.test("any(z1, 0)", xray.DataArray.any(z1, axis=0)))
        assert(ne.test("any(z1, 0, 1)", xray.DataArray.any(z1, axis=(0, 1))))
        assert(ne.test("any(z1, 0, 1, 2)", xray.DataArray.any(z1, axis=(0, 1, 2))))

        assert(ne.test("argmax(z1)", xray.DataArray.argmax(z1)))
        assert(ne.test("argmax(z1, 0)", xray.DataArray.argmax(z1, axis=0)))
        assert(ne.test("argmax(z1, 1)", xray.DataArray.argmax(z1, axis=1)))
        assert(ne.test("argmax(z1, 2)", xray.DataArray.argmax(z1, axis=2)))

        assert(ne.test("argmin(z1)", xray.DataArray.argmin(z1)))
        assert(ne.test("argmin(z1, 0)", xray.DataArray.argmin(z1, axis=0)))
        assert(ne.test("argmin(z1, 1)", xray.DataArray.argmin(z1, axis=1)))
        assert(ne.test("argmin(z1, 2)", xray.DataArray.argmin(z1, axis=2)))

        assert(ne.test("max(z1)", xray.DataArray.max(z1)))
        assert(ne.test("max(z1, 0)", xray.DataArray.max(z1, axis=0)))
        assert(ne.test("max(z1, 0, 1)", xray.DataArray.max(z1, axis=(0, 1))))
        assert(ne.test("max(z1, 0, 1, 2)", xray.DataArray.max(z1, axis=(0, 1, 2))))

        assert(ne.test("mean(z1)", xray.DataArray.mean(z1)))
        assert(ne.test("mean(z1, 0)", xray.DataArray.mean(z1, axis=0)))
        assert(ne.test("mean(z1, 0, 1)", xray.DataArray.mean(z1, axis=(0, 1))))
        assert(ne.test("mean(z1, 0, 1, 2)", xray.DataArray.mean(z1, axis=(0, 1, 2))))

        assert(ne.test("median(z1)", xray.DataArray.median(z1)))
        assert(ne.test("median(z1, 0)", xray.DataArray.median(z1, axis=0)))
        assert(ne.test("median(z1, 0, 1)", xray.DataArray.median(z1, axis=(0, 1))))
        assert(ne.test("median(z1, 0, 1, 2)", xray.DataArray.median(z1, axis=(0, 1, 2))))

        assert(ne.test("min(z1)", xray.DataArray.min(z1)))
        assert(ne.test("min(z1, 0)", xray.DataArray.min(z1, axis=0)))
        assert(ne.test("min(z1, 0, 1)", xray.DataArray.min(z1, axis=(0, 1))))
        assert(ne.test("min(z1, 0, 1, 2)", xray.DataArray.min(z1, axis=(0, 1, 2))))

        assert(ne.test("prod(z1)", xray.DataArray.prod(z1)))
        assert(ne.test("prod(z1, 0)", xray.DataArray.prod(z1, axis=0)))
        assert(ne.test("prod(z1, 0, 1)", xray.DataArray.prod(z1, axis=(0, 1))))
        assert(ne.test("prod(z1, 0, 1, 2)", xray.DataArray.prod(z1, axis=(0, 1, 2))))

        assert(ne.test("sum(z1)", xray.DataArray.sum(z1)))
        assert(ne.test("sum(z1, 0)", xray.DataArray.sum(z1, axis=0)))
        assert(ne.test("sum(z1, 0, 1)", xray.DataArray.sum(z1, axis=(0, 1))))
        assert(ne.test("sum(z1, 0, 1, 2)", xray.DataArray.sum(z1, axis=(0, 1, 2))))

        assert(ne.test("std(z1)", xray.DataArray.std(z1)))
        assert(ne.test("std(z1, 0)", xray.DataArray.std(z1, axis=0)))
        assert(ne.test("std(z1, 0, 1)", xray.DataArray.std(z1, axis=(0, 1))))
        assert(ne.test("std(z1, 0, 1, 2)", xray.DataArray.std(z1, axis=(0, 1, 2))))

        assert(ne.test("var(z1)", xray.DataArray.var(z1)))
        assert(ne.test("var(z1, 0)", xray.DataArray.var(z1, axis=0)))
        assert(ne.test("var(z1, 0, 1)", xray.DataArray.var(z1, axis=(0, 1))))
        assert(ne.test("var(z1, 0, 1, 2)", xray.DataArray.var(z1, axis=(0, 1, 2))))

        assert(ne.test("percentile(z1, 50)", np.percentile(z1, 50)))
        assert(ne.test("percentile(z1, 50)+percentile(z1, 50)",
               np.percentile(z1, 50) + np.percentile(z1, 50)))
        assert(ne.test("1 + var(z1, 0, 0+1, 2) + 1",
               1+xray.DataArray.var(z1, axis=(0, 0+1, 2))+1))

        assert(ne.test("z1{mask1}", xray.DataArray.where(z1, mask1)))
        assert(ne.test("z1{z1>2}", xray.DataArray.where(z1, z1 > 2)))
        assert(ne.test("z1{z1>=2}", xray.DataArray.where(z1, z1 >= 2)))
        assert(ne.test("z1{z1<2}", xray.DataArray.where(z1, z1 < 2)))
        assert(ne.test("z1{z1<=2}", xray.DataArray.where(z1, z1 <= 2)))
        assert(ne.test("z1{z1==2}", xray.DataArray.where(z1, z1 == 2)))
        assert(ne.test("z1{z1!=2}", xray.DataArray.where(z1, z1 != 2)))

        assert(ne.test("z1{z1<2 | z1>5}", xray.DataArray.where(z1, (z1 < 2) | (z1 > 5))))
        assert(ne.test("z1{z1>2 & z1<5}", xray.DataArray.where(z1, (z1 > 2) & (z1 < 5))))

        ne.evaluate("m = z1+1")
        assert(ne.test("m", z1+1))

        assert(ne.test("z1{~mask1}", xray.DataArray.where(z1, ~mask1)))

        assert(ne.test("(1<0?1+1;2+2)", 4))
        assert(ne.test("(0<1?1+1;2+2)", 2))
        assert(ne.test("z1+mask1", xray.DataArray.where(z1, mask1)))

    def test_3(self):
        # perform ndvi bandmath and masking

        g = GDF()
        nd = NDexpr()

        data_request_descriptor = {'storage_type': 'LS5TM',
                                   'variables': ('B30', 'B40'),
                                   'dimensions': {'X': {'range': (147.0, 147.256)},
                                                  'Y': {'range': (-37.0, -36.744)}
                                                  }
                                   }

        d1 = g.get_data(data_request_descriptor)

        pq_request_descriptor = {'storage_type': 'LS5TMPQ',
                                 'variables': ['PQ'],
                                 'dimensions': {'X': {'range': (147.0, 147.256)},
                                                'Y': {'range': (-37.0, -36.744)}
                                                }
                                 }

        d2 = g.get_data(pq_request_descriptor)

        b30 = xray.DataArray(d1['arrays']['B30'])
        b40 = xray.DataArray(d1['arrays']['B40'])
        pq = xray.DataArray(nd.get_pqa_mask(d2['arrays']['PQ']))

        ndvi = nd.evaluate('((b40 - b30) / (b40 + b30))')
        masked_ndvi = nd.evaluate('ndvi{pq}')

    def test_4(self):
        # perform ndvi bandmath and masking and median reduction.

        g = GDF()
        nd = NDexpr()

        data_request_descriptor = {'storage_type': 'LS5TM',
                                   'variables': ('B30', 'B40'),
                                   'dimensions': {'X': {'range': (147.0, 147.256)},
                                                  'Y': {'range': (-37.0, -36.744)}
                                                  }
                                   }

        d1 = g.get_data(data_request_descriptor)

        pq_request_descriptor = {'storage_type': 'LS5TMPQ',
                                 'variables': ['PQ'],
                                 'dimensions': {'X': {'range': (147.0, 147.256)},
                                                'Y': {'range': (-37.0, -36.744)}
                                                }
                                 }

        d2 = g.get_data(pq_request_descriptor)

        b30 = xray.DataArray(d1['arrays']['B30'])
        b40 = xray.DataArray(d1['arrays']['B40'])
        pq = xray.DataArray(nd.get_pqa_mask(d2['arrays']['PQ']))

        ndvi = nd.evaluate('((b40 - b30) / (b40 + b30))')
        masked_ndvi = nd.evaluate('ndvi{pq}')

        reduction1 = nd.evaluate('median(masked_ndvi, 0)')
        reduction2 = nd.evaluate('median(masked_ndvi, 0, 1)')
        reduction3 = nd.evaluate('median(masked_ndvi, 0, 1, 2)')

        assert len(reduction1.dims) == 2
        assert len(reduction2.dims) == 1
        assert len(reduction3.dims) == 0


# Define test suites
def test_suite():
    """Returns a test suite of all the tests in this module."""

    test_classes = [TestNDexpr
                    ]

    suite_list = map(unittest.defaultTestLoader.loadTestsFromTestCase,
                     test_classes)

    suite = unittest.TestSuite(suite_list)

    return suite


# Define main function
def main():
    unittest.TextTestRunner(verbosity=2).run(test_suite())

if __name__ == '__main__':
    main()
