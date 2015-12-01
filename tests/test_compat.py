
from datacube.compat import _make_ctypes_spatialreference


def test_ctypes_spatialreference():
    projection = 'GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],' \
             'AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433],' \
             'AUTHORITY["EPSG","4326"]]'
    SpatialReference = _make_ctypes_spatialreference()
    sr = SpatialReference(projection)
    assert sr.IsGeographic() == True
    assert sr.GetSemiMajor() == 6378137.0
