# Copyright (c) 2023, NVIDIA CORPORATION.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import annotations

import glob
import importlib
import json
import subprocess
import os
import sys
import shutil
import traceback
from ctypes import *
import time
from typing import Final
import pycuda.autoinit

import code.common.arguments as common_args
from code import get_harness, G_HARNESS_CLASS_MAP
from code.actionhandler.base import ActionHandler
from code.actionhandler.generate_conf_files import GenerateConfFilesHandler
from code.common import logging
from code.common.accuracy_checker import check_accuracy
from code.common.constants import *
from code.common.power_limit import ScopedPowerStateController
from code.common.protected_super import ProtectedSuper


HARNESS_METADATA_FILE: Final[str] = "metadata.json"


class RunHarnessHandler(GenerateConfFilesHandler):
    """Handles the RunHarness action. This calls the underlying GenerateConfFilesHandler first to generate the
    measurements/ file required for LoadGen.
    """

    def __init__(self, benchmark_conf, power_controller, use_gpu=True, use_dla=True, profiler=None, measure_power=False, skip_postprocess=False):
        """Creates a new ActionHandler for RunHarness

        Args:
            benchmark_conf (Dict[str, Any]): The benchmark configuration in dictionary form (Legacy behavior)
            power_controller (PowerController): The PowerController to control to power settings of the system
            use_gpu (bool): Whether or not GPUs are used for this configuration.
            use_dla (bool): Whether or not DLAs are used for this configuration
            profiler (str): INTERNAL ONLY. Name of the profiler to use. (Default: None)
            measure_power (bool): INTERNAL ONLY. If True, measures the power usage during the harness run in a
                                  background thread. (Default: False)
            skip_postprocess (bool): If True, skips accuracy log parsing and statistics reporting in cleanup().
                                     (Default: False)
        """
        # Force use_gpu and use_dla to False for non-GPU based harnesses.
        if benchmark_conf["use_cpu"] or benchmark_conf["use_inferentia"]:
            use_gpu, use_dla, profiler = (False, False, None)
        super().__init__(benchmark_conf, use_gpu=use_gpu, use_dla=use_dla, skip_file_checks=False)
        self.action = Action.RunHarness

        self.power_controller = ScopedPowerStateController(power_controller)
        self.profiler = profiler
        self.measure_power = measure_power
        self.power_monitor = None
        self.skip_postprocess = skip_postprocess

        # MLPINF-829: Disable CUDA graphs when there is a profiler
        if self.profiler is not None:
            logging.warn("MLPINF-829: CUDA graphs results in a CUDA illegal memory access when run with a profiler. Force-disabling CUDA graphs.")
            self.benchmark_conf["use_graphs"] = False

        self.config_name = None

    def setup(self):
        """Called once before handle().
        """
        self.power_controller.set_power_state()
        # Generates the measurements/ entries and handle any failures
        with ProtectedSuper(self) as duper:
            duper.run()

        # After measurements/ is generated, set profiler if necessary
        if self.profiler is not None:
            profiler_module_path = G_HARNESS_CLASS_MAP["profiler_harness"].module_path
            if importlib.util.find_spec(profiler_module_path) is None:
                logging.info("Could not load profiler: Are you an internal user?")
            else:
                ProfilerHarness = importlib.import_module(profiler_module_path).ProfilerHarness
                self.harness = ProfilerHarness(self.harness, self.profiler)

        self.log_dir = self.benchmark_conf["log_dir"]

        # If measure_power is requested, start the power monitor
        if self.measure_power:
            if importlib.util.find_spec("code.internal.power_measurements") is None:
                logging.info("Could not load power monitor: Are you an internal user?")
            else:
                PowerMeasurements = importlib.import_module("code.internal.power_measurements").PowerMeasurements
                power_logfile_name = "_".join([
                    self.benchmark_conf.get("config_name"),
                    self.benchmark_conf.get("accuracy_level"),
                    self.benchmark_conf.get("optimization_level"),
                    self.benchmark_conf.get("inference_server")])
                self.power_monitor = PowerMeasurements(os.path.join(self.log_dir,
                                                                    "power_measurements",
                                                                    power_logfile_name))
                self.power_monitor.start()

        self.config_name = "-".join([self.harness.get_system_name(),
                                     self.workload_setting.shortname(),
                                     self.scenario.valstr()])

    def cleanup(self, success: bool):
        """Called after handle(), regardless if it errors.
        """
        self.power_controller.reset_power_state()
        if self.measure_power and self.power_monitor is not None:
            self.power_monitor.stop()

    def create_metadata_json(self, result_data: dict[str, Any], append: bool = False):
        """Helper method to update the summary JSON with a value for the current config and benchmark

        Args:
            result_data (dict): The dict of result data to dump as JSON.
            append (bool): If True, adds result_data to the existing metadata (if any). (Default: False)
        """
        summary_file = os.path.join(self.harness.get_full_log_dir(), HARNESS_METADATA_FILE)
        if append:
            with open(summary_file, 'r') as f:
                md = json.load(f)
                md.update(result_data)
        else:
            md = result_data
        with open(summary_file, "w") as f:
            json.dump(md, f, indent=4, sort_keys=True)

    def _get_result_string(self, result_data):
        if result_data["test_mode"] == "AccuracyOnly":
            return "Accuracy run detected."  # TODO: Print actual accuracy
        else:
            scenario_key = result_data["scenario_key"]
            validity = result_data.get("result_validity", "UNKNOWN_VALIDITY")
            return f"{scenario_key}: {result_data[scenario_key]}, Result is {validity}"

    def handle(self) -> bool:
        """Run the action.

        Returns:
            bool: True if handle() succeeded, False otherwise. Note that this does *NOT* fail if the result is invalid
            or below the accuracy threshold. The boolean return value simply indicates if the harness ran to completion.
        """
        # TODO: Communicate with @garvitk on how to handle this better. Currently, this is necessary because CI/CD
        # parses this to retrieve metadata about the run.
        for key, value in self.benchmark_conf.items():
            print(f"{key} : {value}")

        try:
           #MEDICIÓN ENERGÍA PMLIB
            so_file="/work/pmlib_orin.so"
            pmlib = CDLL(so_file)
            print(type(pmlib))
            print(pmlib.pm_create_counter)
            DOUBLE_10 = c_double * 10
            CHAR_1 = c_char * 1
            CHAR_4 = c_char * 4
            CHAR_16 = c_char * 16
		## Structure definition.
            class PM_MeasuresStruct(Structure):
               _fields_ = ( 
                    ("watts_size", c_int),
                    ("watts_sets_size", c_int),
                    ("watts_sets", POINTER(c_int)),
                    ("watts", POINTER(c_double)),
                    ("lines_len", c_int)
                )

            class PM_MeasuresWTStruct(Structure):
               _fields_ = (
                    ("next_timing", c_int),
                    ("timing", POINTER(c_double)),
                    ("energy", PM_MeasuresStruct)
                )

            class LineStruct(Structure):
               _fields_ = [
                   ("__bits", c_char * 16)
               ]

            class DeviceStruct(Structure):
               _fields_ = (
                    ("name", c_char_p),
                    ("max_frequency", c_int),
                    ("n_lines", c_int),
               )

            class CounterStruct(Structure):
               _fields_ = (
                    ("sock", c_int),
                    ("aggregate", c_int),
                    ("lines", LineStruct),
	            #("lines", CHAR_16),
                    ("num_lines", c_int),
                    ("interval", c_int),
                    ("pm_measures_wt", POINTER(PM_MeasuresWTStruct))
               )

            class ServerStruct(Structure):
               _fields_ = (
                    ("server_ip", c_char * 16),
                    ("port", c_int),
               )
		# Main program
            servidor = ServerStruct()
            contador = CounterStruct()
            lineas = LineStruct( b'1000000000000000')
            disp = DeviceStruct()

	    # Start pm_set_lines
            _pm_set_lines = pmlib.pm_set_lines
            _pm_set_lines.argtypes = [c_char_p,POINTER(LineStruct)]
            _pm_set_lines.restype = c_int
            lines_string = c_char_p(b'8-10')

            _pm_set_lines(lines_string, byref(lineas))
		# End pm_set_lines

		# Start pm_set_server
            _pm_set_server = pmlib.pm_set_server
            _pm_set_server.argtypes = [c_char_p,c_int,POINTER(ServerStruct)]
            _pm_set_server.restype = c_int
			
            ip = c_char_p(b'127.0.0.1')

            for field_name, field_type in servidor._fields_:
              print(field_name, getattr(servidor, field_name))

            _pm_set_server(ip, 6526, byref(servidor))

            for field_name, field_type in servidor._fields_:
              print(field_name, getattr(servidor, field_name))

            # End pm_set_server

            # Start pm_create_counter
            _pm_create_counter = pmlib.pm_create_counter
            _pm_create_counter.argtypes = [c_char_p,LineStruct,c_int,c_int,ServerStruct,POINTER(CounterStruct)]
            _pm_set_server.restype = c_int
         
            device_name = c_char_p(b'ORINAGXDevice')
            _pm_create_counter(device_name, lineas, 0, 0, servidor, byref(contador))

		# End pm_create_counter

	    # Start pm_start_counter
            _pm_start_counter = pmlib.pm_start_counter
            _pm_start_counter.argtypes = [POINTER(CounterStruct)]
            _pm_start_counter.restype = c_int

            _pm_start_counter(byref(contador)) 

           
            #EJECUCION
            result_data = self.harness.run_harness(flag_dict=self.harness_flag_dict, skip_generate_measurements=True)
	

	            # Start pm_stop_counter
            _pm_stop_counter = pmlib.pm_stop_counter
            _pm_stop_counter.argtypes = [POINTER(CounterStruct)]
            _pm_stop_counter.restype = c_int

            _pm_stop_counter(byref(contador))
		# End pm_stop_counter


		# Start pm_get_counter_data
            _pm_get_counter_data = pmlib.pm_get_counter_data
            _pm_get_counter_data.argtypes = [POINTER(CounterStruct)]
            _pm_get_counter_data.restype = c_int

            _pm_get_counter_data(byref(contador))
		# End pm_get_counter_data


		# Start pm_print_data_csv
            _pm_print_data_csv = pmlib.pm_print_data_csv
            _pm_print_data_csv.argtypes = [c_char_p,CounterStruct, LineStruct,c_int]
            _pm_print_data_csv.restype = c_int

            result_data["config_name"] = self.config_name

            result_string = self._get_result_string(result_data)
            result_data["summary_string"] = result_string
            logging.info(f"Result: {result_string}")
            logging.info( self.harness_flag_dict)
            logging.info(self.benchmark_conf.get("config_name"))
            
            files = glob.glob('/work/build/logs/*/stdout.txt')
            files.sort(key=lambda x: os.path.getmtime(x), reverse=True)
            latest_file = files[0]
            qps=None

            nombre_config =  self.benchmark_conf.get("config_name").encode('utf-8')
            config = nombre_config.decode('utf-8').split("_")
            modelo = config[2] 
            batch = "gpu_batch_size : " 
            if modelo == 'Offline' :
                segundo_valor = "offline_expected_qps : "            
            elif modelo == 'Server' :
                segundo_valor = "server_target_qps : "
            elif modelo == 'SingleStream' :
                segundo_valor = "single_stream_expected_latency_ns : "


            with open(latest_file, 'r') as file:
            	for line in file:
                        if batch in line:
                                batch_value = line.split(batch)[1].strip() 
                        if segundo_valor in line:
                                expected = line.split(segundo_valor)[1].strip()
                                break


            file_name = b'test_' + self.benchmark_conf.get("config_name").encode('utf-8') + batch_value.encode('utf-8')  + b'_' + expected.encode('utf-8') + b'.csv'

            _pm_print_data_csv(file_name, contador, lineas, -1)
           	# End print_data_csv
            
            #Move csv
            #ruta_fichero = os.path.abspath(file_name)
            ruta_fichero = os.path.abspath(file_name).decode('utf-8')
            #destino = "/work/resultadosAGX60W"
            #destino = "/work/resultadosAGX15W/energia"
            
            #output_bytes = subprocess.check_output(["sudo", "/usr/sbin/nvpmodel", "-q"])
            #output = output_bytes.decode("utf-8")
            with open("/work/config.txt", 'r') as file:
                content = file.readlines()
            #lines = content.split('\n')
            mode_energy = content[1]
#            if mode_energy == '1':
            destino = "/work/resultadosAGX15W/energia" 
#            else:
#            destino = "/work/resultadosAGX60W"
            if os.path.exists(os.path.join(destino, os.path.basename(ruta_fichero))):
                os.remove(os.path.join(destino, os.path.basename(ruta_fichero)))

            #shutil.move(ruta_fichero, destino, copy_function=shutil.copy2)
            shutil.move(ruta_fichero, destino)
            

		# Start pm_stop_counter
            _pm_finalize_counter = pmlib.pm_finalize_counter
            _pm_finalize_counter.argtypes = [POINTER(CounterStruct)]
            _pm_finalize_counter.restype = c_int

            _pm_finalize_counter(byref(contador))


            if "dlrm_pairs_per_second" in result_data:
                print("User-item pairs per second: {:.3f}".format(result_data["dlrm_pairs_per_second"]))
        except Exception as _:
            traceback.print_exc(file=sys.stdout)
            return False

        if result_data["test_mode"] == "AccuracyOnly":
            acc_results = check_accuracy(os.path.join(self.harness.get_full_log_dir(), "mlperf_log_accuracy.json"),
                                         self.benchmark_conf)

            pass_string_list = ["PASSED" if result_dict['pass'] else "FAILED" for result_dict in acc_results]

            summary_string_list = [
                f"[{pass_string_list[i]}] {result_dict['name']}: {result_dict['value']:.3f} (Threshold={result_dict['threshold']:.3f})" for i, result_dict in enumerate(acc_results)]

            result_data["accuracy"] = acc_results
            result_data["accuracy_pass"] = "FAILED" not in pass_string_list
            result_data["summary_string"] = ' | '.join(summary_string_list)
        self.create_metadata_json(result_data)
        return True

    def handle_failure(self):
        """Called after handle() if it errors.
        """
        raise RuntimeError("Run harness failed!")
