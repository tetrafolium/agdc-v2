# coding=utf-8
# We're using references that don't exist in python 3 (unicode, long):
# pylint: disable=undefined-variable,invalid-name
"""
Compatibility helpers for Python 2 and 3.

See: http://lucumr.pocoo.org/2013/5/21/porting-to-python-3-redux/

"""
import sys

PY2 = sys.version_info[0] == 2

if not PY2:
    text_type = str
    string_types = (str,)
    integer_types = (int,)
    unicode_to_char = chr
    long_int = int

    # Lazy range function
    range = range

    import configparser
    NoOptionError = configparser.NoOptionError

    def read_config(default_text=None):
        config = configparser.ConfigParser()
        if default_text:
            config.read_string(default_text)
        return config

else:
    text_type = unicode
    string_types = (str, unicode)
    integer_types = (int, long)
    unicode_to_char = unichr
    long_int = long

    # Lazy range function
    range = xrange

    import ConfigParser
    from io import StringIO
    NoOptionError = ConfigParser.NoOptionError

    def read_config(default_text=None):
        config = ConfigParser.SafeConfigParser()
        if default_text:
            config.readfp(StringIO(default_text))
        return config


def with_metaclass(meta, *bases):
    class metaclass(meta):
        __call__ = type.__call__
        __init__ = type.__init__

        def __new__(cls, name, this_bases, d):
            if this_bases is None:
                return type.__new__(cls, name, (), d)
            return meta(name, bases, d)

    return metaclass('temporary_class', None, {})


def _make_ctypes_spatialreference():
    import rasterio
    import ctypes

    try:
        _gdal = ctypes.cdll.LoadLibrary('libgdal.so.1')
    except WindowsError:
        _gdal = ctypes.cdll.LoadLibrary('gdal111')

    OSRNewSpatialReference = _gdal.OSRNewSpatialReference
    OSRNewSpatialReference.restype = ctypes.c_void_p

    OSRIsGeographic = _gdal.OSRIsGeographic
    OSRIsGeographic.restype = ctypes.c_bool

    OSRGetSemiMajor = _gdal.OSRGetSemiMajor
    OSRGetSemiMajor.restype = ctypes.c_double

    OSRGetInvFlattening = _gdal.OSRGetInvFlattening
    OSRGetInvFlattening.restype = ctypes.c_double

    OSRGetAttrValue = _gdal.OSRGetAttrValue
    OSRGetAttrValue.restype = str

    class SpatialReference(object):
        def __init__(self, arg=""):
            self.sr = OSRNewSpatialReference(arg)

        def IsGeographic(self):
            return OSRIsGeographic(self.sr)

        def GetSemiMajor(self):
            return OSRGetSemiMajor(self.sr, 0)

        def GetInvFlattening(self):
            return OSRGetInvFlattening(self.sr, 0)


        def GetAttrValue(self, key, attr=0):
            return OSRGetAttrValue(self.sr, key, attr)

    return SpatialReference

try:
    from osgeo.osr import SpatialReference
except ImportError:
    SpatialReference = _make_ctypes_spatialreference()
