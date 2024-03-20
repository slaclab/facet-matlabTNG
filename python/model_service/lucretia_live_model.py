# adapted by dcesar from https://github.com/slaclab/lcls_live_model/blob/master/live_model.py#L343

import os
import logging
import argparse
import threading
from typing import Optional, List, Dict, Any
from functools import lru_cache
import numpy as np
import time
import epics
from p4p.nt import NTTable
from p4p.server import Server as PVAServer
from p4p.server.thread import SharedPV
import matlab.engine

heartbeat_pv=epics.PV('PHYS:SYS1:1:MODEL_SERVER') #used below. This is a "watcher pv" made for us by M.Zelazny. It makes F2:WATCHER:MODEL_SERVER_STAT alert if it is not written to every 30s or so.

twiss_table_type = NTTable([
    ("element", "s"), ("device_name", "s"),
    ("s", "d"), ("z", "d"), ("length", "d"), ("p0c", "d"),
    ("alpha_x", "d"), ("beta_x", "d"), ("eta_x", "d"), ("etap_x", "d"), ("psi_x", "d"),
    ("alpha_y", "d"), ("beta_y", "d"), ("eta_y", "d"), ("etap_y", "d"), ("psi_y", "d")])

rmat_table_type = NTTable([
    ("element", "s"), ("device_name", "s"), ("s", "d"), ("z", "d"), ("length", "d"),
    ("r11", "d"), ("r12", "d"), ("r13", "d"), ("r14", "d"), ("r15", "d"), ("r16", "d"),
    ("r21", "d"), ("r22", "d"), ("r23", "d"), ("r24", "d"), ("r25", "d"), ("r26", "d"),
    ("r31", "d"), ("r32", "d"), ("r33", "d"), ("r34", "d"), ("r35", "d"), ("r36", "d"),
    ("r41", "d"), ("r42", "d"), ("r43", "d"), ("r44", "d"), ("r45", "d"), ("r46", "d"),
    ("r51", "d"), ("r52", "d"), ("r53", "d"), ("r54", "d"), ("r55", "d"), ("r56", "d"),
    ("r61", "d"), ("r62", "d"), ("r63", "d"), ("r64", "d"), ("r65", "d"), ("r66", "d")])


class ModelRunner:
    """ModelRunner launches a matlab_instance and starts at Lucretia live model. The live model then tracks the machine as long as the matlab instance is still running."""

    def __init__(self):
        # Start matlab engine and F2_Live
        os.chdir('/usr/local/facet/tools/matlabTNG/')
        logging.debug("Starting matlab...")
        self.eng = matlab.engine.start_matlab()
        logging.debug("Starting F2_LiveModelApp...")
        self.eng.eval('f2_live=F2_LiveModelApp; global BEAMLINE;',nargout=0)
        logging.debug("F2_live now running")
        self.beamline=self.eng.workspace['BEAMLINE'];
        # Synchronous running parameters
        self.model_lock = threading.Lock()
        self.last_update_failed = True

    def update_forever(self):
        while True:
            with self.model_lock:
                # self.update_model() # not needed, L2_LiveModelApp is doing this under the hood for us
                time.sleep(1.0)

    @lru_cache()
    def get_ele_name_list(self) -> List[str]:
        """
        Get the list of all element names.  Used to populate the NTTable data.
        This is cached using lru_cache, so repeated accesses are fast.
        """
        self.beamline=self.eng.workspace['BEAMLINE'];
        ele_name_list = [x['Name'] for x in  self.beamline]
        return ele_name_list

    @lru_cache()
    def get_z_vals(self) -> List[float]:
        """
        Get a list of all z locations for items.
        This list is ordered in the same way that `get_ele_name_list` is. It is as up-to-date as get_ele_name_list.
        """
        #zs = [float(x['S']) for x in  self.beamline] This is actually the "s" position..
        zs=[(x['Coordf'][0][2]+x['Coordi'][0][2])/2 for x in self.beamline]
        return zs

    def get_model_tables(self, uncombined=False):
        """
        Queries Lucretia for model and RMAT info.
        Returns: A (twiss_table, rmat_table) tuple.
        
        Only take tables for the first instance of an element. For a split quad this will give us an evaluation in the middle of the quad.
        """
        with self.model_lock:
            start_time = time.time()
            # First we get a list of all the elements and z positions
            element_name_list = self.get_ele_name_list()
            z_vals = self.get_z_vals()
            # Get list of all twiss parameters once
            self.eng.eval('Initial=f2_live.Initial; [~,twiss] = GetTwiss(1,{:d},Initial.x.Twiss,Initial.y.Twiss);'.format(len(z_vals)),nargout=0)
            twiss=self.eng.workspace['twiss']
            # Now loop over elements
            rmat_table_rows=[];
            twiss_table_rows=[];
            for ii,ele in enumerate(self.beamline):
            
                # Get device name if possible    
                try:
                    device_name=self.eng.model_nameConvert(ele['Name'],'device');
                except:
                    device_name = ""
                # Length in model   
                if  'L' in ele.keys():
                    length=ele['L']
                else:
                    length=0
                # matrix
                if uncombined:
                    self.eng.eval('[~,rmat]=RmatAtoB({:d},{:d});'.format(ii+1,ii+1),nargout=0)
                else:
                    self.eng.eval('[~,rmat]=RmatAtoB(1,{:d});'.format(ii+1),nargout=0)
                rmat=self.eng.workspace['rmat'];    
                rmat_table_rows.append({
                    "element": ele['Name'], "device_name": device_name, "s": ele['S'], "z": z_vals[ii], "length": length,
                    "r11": rmat[0][0], "r12": rmat[0][1], "r13": rmat[0][2], "r14": rmat[0][3], "r15": rmat[0][4], "r16": rmat[0][5],
                    "r21": rmat[1][0], "r22": rmat[1][1], "r23": rmat[1][2], "r24": rmat[1][3], "r25": rmat[1][4], "r26": rmat[1][5],
                    "r31": rmat[2][0], "r32": rmat[2][1], "r33": rmat[2][2], "r34": rmat[2][3], "r35": rmat[2][4], "r36": rmat[2][5],
                    "r41": rmat[3][0], "r42": rmat[3][1], "r43": rmat[3][2], "r44": rmat[3][3], "r45": rmat[3][4], "r46": rmat[3][5],
                    "r51": rmat[4][0], "r52": rmat[4][1], "r53": rmat[4][2], "r54": rmat[4][3], "r55": rmat[4][4], "r56": rmat[4][5],
                    "r61": rmat[5][0], "r62": rmat[5][1], "r63": rmat[5][2], "r64": rmat[5][3], "r65": rmat[5][4], "r66": rmat[5][5]})
                 
                #p0c in eV to match bmad  default ...
                
                twiss_table_rows.append({"element": ele['Name'], "device_name": device_name, "s": ele['S'], "z": z_vals[ii], "length": length,"p0c":ele['P']*1e9,
                            "alpha_x": twiss['alphax'][0][ii], "beta_x": twiss['betax'][0][ii], "eta_x": twiss['etax'][0][ii], "etap_x": twiss['etapx'][0][ii], "psi_x": twiss['nux'][0][ii],
                            "alpha_y": twiss['alphay'][0][ii], "beta_y": twiss['betay'][0][ii], "eta_y": twiss['etay'][0][ii], "etap_y": twiss['etapy'][0][ii], "psi_y": twiss['nuy'][0][ii]})
                            
            twiss_table = twiss_table_type.wrap(twiss_table_rows)
            rmat_table = rmat_table_type.wrap(rmat_table_rows)
            sec, nanosec = divmod(float(time.time()), 1.0)
            for table in (twiss_table, rmat_table):
                table['timeStamp']['secondsPastEpoch'] = sec
                table['timeStamp']['nanoseconds'] = nanosec
            end_time = time.time()
            logging.debug("get_model_tables took %f seconds", end_time - start_time)
            return twiss_table, rmat_table


if __name__ == "__main__":
    logging.info("Starting FACET Lucretia Live Model Service.")
    parser = argparse.ArgumentParser(description="Live Model Service")
    parser.add_argument(
        '--loglevel',
        help='Configure level of log display',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
        default='INFO')
    parser.add_argument(
        '--logpath',
        help='Directory where logs get saved.',
        default='/u1/facet/matlab/log/')
    parser.add_argument(
        '--pv_prefix',
        help='String to use for the first part of the PV.',
        type=str,
        default="LUCRETIA")
    parser.add_argument(
        '--design_only',
        help='Disable live value updating (the live PVs will still be accessible, but will be static)',
        action='store_true'
    )
    model_name='FACET2E';
    model_service_args = parser.parse_args()
    LOG_LEVEL = model_service_args.loglevel
    LOG_PATH = model_service_args.logpath
    logfile = os.path.join(LOG_PATH,'FACET_LUCRETIA_MODEL' , 'live_model.log')
    stream_handler = logging.StreamHandler()
    file_handler = logging.FileHandler(logfile)
    logging.basicConfig(
        handlers=[stream_handler, file_handler],
        level=LOG_LEVEL,
        format="%(asctime)s,%(msecs)d %(levelname)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        force=True
    )

    model = ModelRunner()
    initial_twiss_table, initial_rmat_table = model.get_model_tables()
    _, initial_uncombined_rmat_table = model.get_model_tables(uncombined=True)
    logging.debug("Creating PVA Server")
    live_twiss_pv = SharedPV(nt=twiss_table_type, initial=initial_twiss_table)
    design_twiss_pv = SharedPV(nt=twiss_table_type, initial=initial_twiss_table)
    live_rmat_pv = SharedPV(nt=rmat_table_type, initial=initial_rmat_table)
    design_rmat_pv = SharedPV(nt=rmat_table_type, initial=initial_rmat_table)
    live_u_rmat_pv = SharedPV(nt=rmat_table_type, initial=initial_uncombined_rmat_table)
    design_u_rmat_pv = SharedPV(nt=rmat_table_type, initial=initial_uncombined_rmat_table)
    # Map the PVs to PV names
    pv_provider = {
        f"{model_service_args.pv_prefix.upper()}:SYS0:1:{model_name.upper()}:LIVE:TWISS": live_twiss_pv,
        f"{model_service_args.pv_prefix.upper()}:SYS0:1:{model_name.upper()}:DESIGN:TWISS": design_twiss_pv,
        f"{model_service_args.pv_prefix.upper()}:SYS0:1:{model_name.upper()}:LIVE:RMAT": live_rmat_pv,
        f"{model_service_args.pv_prefix.upper()}:SYS0:1:{model_name.upper()}:DESIGN:RMAT": design_rmat_pv,
        f"{model_service_args.pv_prefix.upper()}:SYS0:1:{model_name.upper()}:LIVE:URMAT": live_u_rmat_pv,
        f"{model_service_args.pv_prefix.upper()}:SYS0:1:{model_name.upper()}:DESIGN:URMAT": design_u_rmat_pv
    }
    # Start up the PVAccess server.
    with PVAServer(providers=[pv_provider]):
        if not model_service_args.design_only:
            # Start collecting live data on a separate thread
            logging.debug("Starting model calculation")
            model_calculation_thread = threading.Thread(target=model.update_forever, daemon=True)
            model_calculation_thread.start()
        try:
            ii=0
            while True:
                ii=np.mod(ii+1,100)
                heartbeat_pv.put(ii,100)
                time.sleep(2.0)
                if not model_service_args.design_only:
                    twiss_table, rmat_table = model.get_model_tables()
                    _, urmat_table = model.get_model_tables(uncombined=True);
                    live_twiss_pv.post(twiss_table)
                    live_rmat_pv.post(rmat_table)
                    live_urmat_pv.post(urmat_table)
        except KeyboardInterrupt:
            pass
        finally:
            logging.info("Stopping service.")
