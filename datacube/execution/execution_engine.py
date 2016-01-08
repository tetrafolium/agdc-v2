# ------------------------------------------------------------------------------
# Name:       execution_engine.py
# Purpose:    Execution Engine
#
# Author:     Peter Wang
#
# Created:    14 July 2015
# Copyright:  2015 Commonwealth Scientific and Industrial Research Organisation
#             (CSIRO)
# License:    This software is open source under the Apache v2.0 License
#             as provided in the accompanying LICENSE file or available from
#             https://github.com/data-cube/agdc-v2/blob/master/LICENSE
#             By continuing, you acknowledge that you have read and you accept
#             and will abide by the terms of the License.
#
# Updates:
# 7/10/2015:  Initial Version.
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import
from __future__ import print_function
import sys
import numpy as np
import numexpr as ne
import copy
from pprint import pprint
import gdal
import osr

import logging

from datacube.gdf import GDF
from datacube.api import API
from datacube.analytics.analytics_engine import OPERATION_TYPE
from datacube.analytics.utils.analytics_utils import get_pqa_mask
from datacube.ndexpr import NDexpr

#from datacube.analytics.utils import memory

import xray
from xray import ufuncs
import inspect

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)  # Logging level for this module


class ExecutionEngine(object):

    REDUCTION_FNS = {"all": xray.DataArray.all,
                     "any": xray.DataArray.any,
                     "argmax": xray.DataArray.argmax,
                     "argmin": xray.DataArray.argmin,
                     "max": xray.DataArray.max,
                     "mean": xray.DataArray.mean,
                     "median": xray.DataArray.median,
                     "min": xray.DataArray.min,
                     "prod": xray.DataArray.prod,
                     "sum": xray.DataArray.sum,
                     "std": xray.DataArray.std,
                     "var": xray.DataArray.var}

    def __init__(self, gdf=False):
        logger.debug('Initialise Execution Module.')
        self.cache = {}
        self.nd = NDexpr()
        self.nd.setAE(True)

        self.use_gdf = gdf
        if self.use_gdf:
            self.gdf = GDF()
            self.gdf.debug = False
        else:
            self.api = API()

    def executePlan(self, plan):

        for task in plan:
            function = task.values()[0]['orig_function']
            #expression = task.values()[0]['expression']
            op_type = task.values()[0]['operation_type']
            print('function =', function)

            if op_type == OPERATION_TYPE.Get_Data:
                self.executeGetData(task)
            elif op_type == OPERATION_TYPE.Expression:
                self.executeExpression(task)
            elif op_type == OPERATION_TYPE.Cloud_Mask:
                self.executeCloudMask(task)
            elif op_type == OPERATION_TYPE.Reduction and \
                    len([s for s in self.REDUCTION_FNS.keys() if s in function]) > 0:
                self.executeReduction(task)
            elif op_type == OPERATION_TYPE.Bandmath:
                self.executeBandmath(task)

    def executeGetData(self, task):

        if self.use_gdf:
            data_request_param = {}
            data_request_param['dimensions'] = task.values()[0]['array_input'][0].values()[0]['dimensions']
            data_request_param['storage_type'] = task.values()[0]['array_input'][0].values()[0]['storage_type']
            data_request_param['variables'] = ()

            for array in task.values()[0]['array_input']:
                data_request_param['variables'] += (array.values()[0]['variable'],)

            data_response = self.gdf.get_data(data_request_param)

            no_data_value = task.values()[0]['array_output']['no_data_value']

            if no_data_value is not None:
                for k, v in data_response['arrays'].items():
                    data_response['arrays'][k] = data_response['arrays'][k].where(v != no_data_value)

            key = task.keys()[0]
            self.cache[key] = {}
            self.cache[key]['array_result'] = copy.deepcopy(data_response['arrays'])
            self.cache[key]['array_indices'] = copy.deepcopy(data_response['indices'])
            self.cache[key]['array_dimensions'] = copy.deepcopy(data_response['dimensions'])
            self.cache[key]['array_output'] = copy.deepcopy(task.values()[0]['array_output'])

            del data_request_param
            del data_response

            return self.cache[key]
        else:
            data_request_param = {}
            data_request_param['dimensions'] = task.values()[0]['array_input'][0].values()[0]['dimensions']
            data_request_param['storage_type'] = task.values()[0]['array_input'][0].values()[0]['storage_type']
            data_request_param['product'] = task.values()[0]['array_input'][0].values()[0]['product']
            data_request_param['storage_type'] = task.values()[0]['array_input'][0].values()[0]['storage_type']
            data_request_param['variables'] = ()

            for array in task.values()[0]['array_input']:
                data_request_param['variables'] += (array.values()[0]['variable'],)

            data_response = self.api.get_data(data_request_param)

            no_data_value = task.values()[0]['array_output']['no_data_value']

            if no_data_value is not None:
                for k, v in data_response['arrays'].items():
                    data_response['arrays'][k] = data_response['arrays'][k].where(v != no_data_value)

            key = task.keys()[0]
            self.cache[key] = {}
            self.cache[key]['array_result'] = copy.deepcopy(data_response['arrays'])
            self.cache[key]['array_indices'] = copy.deepcopy(data_response['indices'])
            self.cache[key]['array_dimensions'] = copy.deepcopy(data_response['dimensions'])
            self.cache[key]['array_output'] = copy.deepcopy(task.values()[0]['array_output'])

            del data_request_param
            del data_response

            return self.cache[key]

    def executeCloudMask(self, task):

        key = task.keys()[0]
        data_key = task.values()[0]['array_input'][0]
        mask_key = task.values()[0]['array_mask']
        no_data_value = task.values()[0]['array_output']['no_data_value']
        print('key =', key)
        print('data key =', data_key)
        print('data mask_key =', mask_key)
        print('no_data_value =', no_data_value)

        array_desc = self.cache[task.values()[0]['array_input'][0]]

        data_array = self.cache[data_key]['array_result'].values()[0]
        mask_array = self.cache[mask_key]['array_result'].values()[0]

        pqa_mask = get_pqa_mask(mask_array.values)

        masked_array = xray.DataArray.where(data_array, pqa_mask)
        #masked_array = masked_array.fillna(no_data_value)

        self.cache[key] = {}

        self.cache[key]['array_result'] = {}
        self.cache[key]['array_result'][key] = masked_array
        self.cache[key]['array_indices'] = copy.deepcopy(array_desc['array_indices'])
        self.cache[key]['array_dimensions'] = copy.deepcopy(array_desc['array_dimensions'])
        self.cache[key]['array_output'] = copy.deepcopy(task.values()[0]['array_output'])

    def executeExpression(self, task):

        print("===============================================")
        pprint(task)
        key = task.keys()[0]
        no_data_value = task.values()[0]['array_output']['no_data_value']

        # TODO: check all input arrays are the same shape and parameters

        pprint(task)
        arrays = {}
        for task_name in task.values()[0]['array_input']:
            arrays[task_name] = self.cache[task_name]['array_result'].values()[0]
            #arrays.update(self.cache[task_name]['array_result'])

        for i in arrays.keys():
            arrays[i] = arrays[i].where(arrays[i] != no_data_value)

        print('expression =', task.values()[0]['function'])

        arrayResult = {}
        arrayResult['array_result'] = {}
        arrayResult['array_result'][key] = self.nd.evaluate(task.values()[0]['function'],  local_dict=arrays)
        #arrayResult['array_result'][key] = arrayResult['array_result'][key].fillna(no_data_value)

        array_desc = self.cache[task.values()[0]['array_input'][0]]

        arrayResult['array_indices'] = copy.deepcopy(array_desc['array_indices'])
        arrayResult['array_dimensions'] = copy.deepcopy(array_desc['array_dimensions'])
        arrayResult['array_output'] = copy.deepcopy(task.values()[0]['array_output'])

        self.cache[key] = arrayResult
        print("===============================================")
        return self.cache[key]

    def executeBandmath(self, task):

        key = task.keys()[0]

        # TODO: check all input arrays are the same shape and parameters

        arrays = {}
        for task_name in task.values()[0]['array_input']:
            for k, v in self.cache[task_name]['array_result'].items():
                arrays[k] = v.astype(float).values
            #arrays.update(self.cache[task_name]['array_result'])

        arrayResult = {}
        arrayResult['array_result'] = {}
        arrayResult['array_result'][key] = xray.DataArray(ne.evaluate(task.values()[0]['function'],  arrays))
        #arrayResult['array_result'][key] = self.nd.evaluate(task.values()[0]['function'],  arrays)

        array_desc = self.cache[task.values()[0]['array_input'][0]]

        arrayResult['array_indices'] = copy.deepcopy(array_desc['array_indices'])
        arrayResult['array_dimensions'] = copy.deepcopy(array_desc['array_dimensions'])
        arrayResult['array_output'] = copy.deepcopy(task.values()[0]['array_output'])

        self.cache[key] = arrayResult
        return self.cache[key]

    def executeReduction(self, task):

        function_name = task.values()[0]['orig_function'].replace(")", " ").replace("(", " ").split()[0]
        #func = getattr(np, function_name)
        func = self.REDUCTION_FNS[function_name]

        key = key = task.keys()[0]
        data_key = task.values()[0]['array_input'][0]
        #print('key =', key)
        #print('data key =', data_key)

        data = self.cache[data_key]['array_dimensions']

        no_data_value = task.values()[0]['array_output']['no_data_value']

        array_data = self.cache[data_key]['array_result'].values()[0]

        array_desc = self.cache[task.values()[0]['array_input'][0]]

        arrayResult = {}
        arrayResult['array_result'] = {}
        arrayResult['array_output'] = copy.deepcopy(task.values()[0]['array_output'])

        pprint(self.cache[data_key]['array_dimensions'])
        pprint(task.values()[0]['dimension'])

        dims = tuple((self.cache[data_key]['array_dimensions'].index(p) for p in task.values()[0]['dimension']))
        print('dim =', dims)

        args = {}
        if function_name == 'argmax' or function_name == 'argmin':
            if len(dims) != 1:
                args['axis'] = dims[0]
        else:
            args['axis'] = dims

        if 'skipna' in inspect.getargspec(self.REDUCTION_FNS[function_name])[0] and \
           function_name != 'prod':
            args['skipna'] = True

        arrayResult['array_result'][key] = func(array_data, **args)
        arrayResult['array_indices'] = copy.deepcopy(array_desc['array_indices'])
        arrayResult['array_dimensions'] = copy.deepcopy(arrayResult['array_output']['dimensions_order'])

        pprint(array_desc['array_indices'])
        pprint(arrayResult['array_dimensions'])
        if self.use_gdf:
            for index in array_desc['array_indices']:
                if index not in arrayResult['array_dimensions'] and index in arrayResult['array_indices']:
                    del arrayResult['array_indices'][index]
        else:
            for index in range(0, len(task.values()[0]['dimension'])):
                del arrayResult['array_indices'][index]
        self.cache[key] = arrayResult
        return self.cache[key]
        '''
        if len(task.values()[0]['dimension']) == 1:  # 3D -> 2D reduction
            pprint(self.cache[data_key]['array_dimensions'])
            dim = self.cache[data_key]['array_dimensions'].index(task.values()[0]['dimension'][0])

            pprint(array_data)
            arrayResult['array_result'][key] = xray.DataArray.median(array_data, axis=dim)
            #arrayResult['array_result'][key] = np.apply_along_axis(
            #    lambda x: func(x[x != no_data_value]), dim, array_data)

            arrayResult['array_indices'] = copy.deepcopy(array_desc['array_indices'])
            arrayResult['array_dimensions'] = copy.deepcopy(arrayResult['array_output']['dimensions_order'])

            for index in array_desc['array_indices']:
                if index not in arrayResult['array_dimensions'] and index in arrayResult['array_indices']:
                    del arrayResult['array_indices'][index]
        elif len(task.values()[0]['dimension']) == 2:  # 3D -> 1D reduction
            size = task.values()[0]['array_output']['shape'][0]
            print('size =', size)
            out = np.empty([size])
            dim = self.cache[data_key]['array_dimensions'].index(
                task.values()[0]['array_output']['dimensions_order'][0])
            print('dim =', dim)

            #to fix bug in gdf
            size = self.cache[data_key]['array_result'].values()[0].shape[dim]
            print('size =', size)
            out = np.empty([size])

            for i in range(size):

                if np.sum(array_data[i, :, :] != no_data_value) == 0:
                    out[i] = no_data_value
                elif dim == 0:
                    out[i] = func(array_data[i, :, :][array_data[i, :, :] != no_data_value])
                elif dim == 1:
                    out[i] = func(array_data[:, i, :][array_data[:, i, :] != no_data_value])
                elif dim == 2:
                    out[i] = func(array_data[:, :, i][array_data[:, :, i] != no_data_value])

                if np.isnan(out[i]):
                    out[i] = no_data_value

            arrayResult['array_result'][key] = out
            arrayResult['array_indices'] = copy.deepcopy(array_desc['array_indices'])
            arrayResult['array_dimensions'] = copy.deepcopy(arrayResult['array_output']['dimensions_order'])

            for index in array_desc['array_indices']:
                if index not in arrayResult['array_dimensions'] and index in arrayResult['array_indices']:
                    del arrayResult['array_indices'][index]

        self.cache[key] = arrayResult
        return self.cache[key]
        '''
