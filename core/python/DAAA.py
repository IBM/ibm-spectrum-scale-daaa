#!/usr/bin/env python3
#
# Copyright 2020 IBM Corporation
# and other contributors as indicated by the @author tags.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

########################################
# Data Accelerator for AI and Analytics
# Very basic code without any error handling, just to demonstrate the concept, do not use in production

import configparser
import random
import string
import os
import glob
import requests
import json
import subprocess
import time
import sys
import urllib3

class DAAA:

    # Class variables
    config = None
    uniqueId = ''.join(random.choice(string.ascii_lowercase) for i in range(10)) + "_"
    fileList = {}
    nextAction = ""
    status = ""
    lastQuery = ""


    def __init__(self, configFile):
        self.configFile = configFile
        self._readConfigFile(self.configFile)


    # internal functions
    def _readConfigFile(self, configFile):
        print('read config: ' + configFile)
        self.config = configparser.ConfigParser()
        self.config.read(configFile)
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning) # only done as we call "verify=False" on purpose
        
    def _discover_search(self, queryString, action, arconly):
        # get token
        result = requests.get("https://" + self.config['discover']['rest_server'] + "/auth/v1/token", auth=(self.config['discover']['rest_user'], self.config['discover']['rest_password']), verify=False)
        if result.status_code != 200 or 'X-Auth-Token' not in result.headers:
            print("Could not get authoriation token. Please check your credentials.")
            sys.exit(-1)
        auth = "Bearer " + result.headers['X-Auth-Token']
        
        # search
        result = requests.post("https://" + self.config['discover']['rest_server'] + "/db2whrest/v1/search", headers={'Authorization': auth, 'Content-type': 'application/json'}, json={'query': queryString, 'filters': [], 'group_by': [], 'sort_by': [], 'limit': 100000}, verify=False )
        print(result.status_code)
        
        # create file lists
        self._createFileLists(result.json(), action, arconly)

    def _createFileLists(self, resultJson, action, arconly):
    
        if 'rows' not in resultJson:
            return
            
        if arconly == False:
            self.fileList.clear()
        else:
            if 'Archive' in self.fileList:
                self.fileList['Archive'] = []

        archiveActions = []
        
        for entry in json.loads(resultJson['rows']):
            if arconly == False:
                if entry['platform'] in self.fileList:
                    self.fileList[entry['platform']].append(self._createPath(entry))
                else:
                    self.fileList[entry['platform']] = [self._createPath(entry)]
            
            if entry['platform'] == self.config['discover']['connection_platform_arc']:
                if action == "prefetch" and entry['state'] != "resdnt" and entry['state'] != "premig":
                    archiveActions.append(entry['path'] + entry['filename'])
                elif action == "evict" and entry['state'] != "migrtd":
                    archiveActions.append(entry['path'] + entry['filename'])
                    
        if len(archiveActions) > 0:
            self.fileList['Archive'] = archiveActions
       
    def _createPath(self, entry):
        if entry['platform'] == self.config['discover']['connection_platform_nfs']:
            return self.config['gpfs']['gpfs_fs_path'] + self.config['gpfs']['nfs_fset'] + "/" + entry['path'][len(self.config['nfs']['nfs_server_base_path']):] + entry['filename']
        elif entry['platform'] == self.config['discover']['connection_platform_obj']:
            return self.config['gpfs']['gpfs_fs_path'] + self.config['gpfs']['cos_fset'] + "/" + entry['filename']
        elif entry['platform'] == self.config['discover']['connection_platform_arc']:
            return self.config['gpfs']['gpfs_fs_path'] + self.config['gpfs']['arc_fset'] + "/" + entry['path'][len(self.config['archive']['archive_base_path']):] + entry['filename']
    
    def _scpFile(self, file, dest):
        proc = subprocess.Popen(["scp", file, dest])
        waitres = os.waitpid(proc.pid, 0)
    
    def _ssh(self, params, wait=True):
        proc = subprocess.Popen(params)
        if wait == True:
            waitres = os.waitpid(proc.pid, 0)
        else:
            return proc
        
    def _listToFile(self, list, filename):
        with open(filename, 'w') as f:
            for item in list:
                f.write("%s\n" % item)

    def _printStatus(self):
        if self.config['general']['print_status_always'] == "True":
            print(self.getStatus())


    # external functions
    def getStatus(self):
        availableStrg = {}
        for strg in self.fileList:
            availableStrg[strg] = len(self.fileList[strg])
        
        retData = json.loads('{ "uniqueId": "' + self.uniqueId + '", "lastQuery": ' + json.dumps(self.lastQuery) + ', "nextAction": "' + self.nextAction + '", "status": "' + self.status + '", "availableData": ' + json.dumps(availableStrg) + ' }')
        return json.dumps(retData, indent=4)
        
    def getConfig(self):
        for section in self.config.sections():
            print("\n=== " + section + " ===")
            for option in self.config.options(section):
                print(option + "=" + self.config.get(section, option))
    
    def getFileLists(self, type=[]):
        print("=== File Lists ===")
        if not self.fileList:
            print("Empty")
        for strg in self.fileList:
            if strg in type or len(type) == 0:
                print(strg)
                print(self.fileList[strg])

    def searchDiscover(self, tagsToSearchArr="", action="prefetch", arconly=False):
        if tagsToSearchArr == "" and self.lastQuery == "":
            print("Please provide tags to search.")
            sys.exit(-1)
        if tagsToSearchArr != "":
            self.lastQuery = tagsToSearchArr
        
        self.status = ""
        self.nextAction = action
        queryString = ' and '.join(self.lastQuery)
        resultsFile = self._discover_search(queryString, action, arconly)
        self._printStatus()
 
    def recallArchive(self):
        if 'Archive' in self.fileList and len(self.fileList['Archive']) > 0:
            if self.nextAction == "evict":
                print("Next Action is evict which does not fit the recall from tape process.")
                sys.exit(-1)
                
            # need to scp and execute
            self._listToFile(self.fileList['Archive'], "/tmp/" + self.uniqueId + "recall.txt")
            self._scpFile("/tmp/" + self.uniqueId + "recall.txt", self.config['archive']['archive_user'] + "@" + self.config['archive']['archive_server'] + ":" + self.config['archive']['archive_home_path'] + self.uniqueId + "recall.txt")
            self._ssh(["ssh", "-t", self.config['archive']['archive_user'] + "@" + self.config['archive']['archive_server'], self.config['archive']['archive_sudo'] + " /opt/ibm/ltfsee/bin/eeadm", "recall", self.config['archive']['archive_home_path'] + self.uniqueId + "recall.txt"])
        self._printStatus()

    def cacheDataIn(self):
        if self.nextAction == "evict":
            print("Next Action is evict which does not fit the prefetch data process.")
            sys.exit(-1)
        
        procsToWait = []
        for strg in self.fileList:
            if strg == self.config['discover']['connection_platform_nfs']:
                self._listToFile(self.fileList[strg], "/tmp/" + self.uniqueId + "prefetch_nfs.txt")
                self._scpFile("/tmp/" + self.uniqueId + "prefetch_nfs.txt", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'] + ":" + self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "prefetch_nfs.txt")
                procsToWait.append(self._ssh(["ssh", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/afmExec.sh", "prefetch", self.config['gpfs']['gpfs_fs'], self.config['gpfs']['nfs_fset'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "prefetch_nfs.txt", self.config['general']['content_file'], self.config['gpfs']['gpfs_fs_path']], False))
            elif strg == self.config['discover']['connection_platform_obj']:
                self._listToFile(self.fileList[strg], "/tmp/" + self.uniqueId + "prefetch_obj.txt")
                self._scpFile("/tmp/" + self.uniqueId + "prefetch_obj.txt", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'] + ":" + self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "prefetch_obj.txt")
                procsToWait.append(self._ssh(["ssh", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/afmExec.sh", "prefetch", self.config['gpfs']['gpfs_fs'], self.config['gpfs']['cos_fset'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "prefetch_obj.txt", self.config['general']['content_file'], self.config['gpfs']['gpfs_fs_path']], False))
            elif strg == self.config['discover']['connection_platform_arc']:
                self._listToFile(self.fileList[strg], "/tmp/" + self.uniqueId + "prefetch_arc.txt")
                self._scpFile("/tmp/" + self.uniqueId + "prefetch_arc.txt", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'] + ":" + self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "prefetch_arc.txt")
                procsToWait.append(self._ssh(["ssh", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/afmExec.sh", "prefetch", self.config['gpfs']['gpfs_fs'], self.config['gpfs']['arc_fset'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "prefetch_arc.txt", self.config['general']['content_file'], self.config['gpfs']['gpfs_fs_path']], False))

        for proc in procsToWait:
            os.waitpid(proc.pid, 0)

        self.status = "done"
        self._printStatus()

    def runAnalytics(self):
        time.sleep(10)
        print("tobe done")
        self._printStatus()

    def evictDataOut(self):
        if self.nextAction == "prefetch":
            print("Next Action is prefetch which does not fit the evict data process.")
            sys.exit(-1)
            
        procsToWait = []
        for strg in self.fileList:
            if strg == self.config['discover']['connection_platform_nfs']:
                self._listToFile(self.fileList[strg], "/tmp/" + self.uniqueId + "evict_nfs.txt")
                self._scpFile("/tmp/" + self.uniqueId + "evict_nfs.txt", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'] + ":" + self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "evict_nfs.txt")
                procsToWait.append(self._ssh(["ssh", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/afmExec.sh", "evict", self.config['gpfs']['gpfs_fs'], self.config['gpfs']['nfs_fset'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "evict_nfs.txt", self.config['general']['content_file'], self.config['gpfs']['gpfs_fs_path']], False))
            elif strg == self.config['discover']['connection_platform_obj']:
                self._listToFile(self.fileList[strg], "/tmp/" + self.uniqueId + "evict_obj.txt")
                self._scpFile("/tmp/" + self.uniqueId + "evict_obj.txt", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'] + ":" + self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "evict_obj.txt")
                procsToWait.append(self._ssh(["ssh", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/afmExec.sh", "evict", self.config['gpfs']['gpfs_fs'], self.config['gpfs']['cos_fset'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "evict_obj.txt", self.config['general']['content_file'], self.config['gpfs']['gpfs_fs_path']], False))
            elif strg == self.config['discover']['connection_platform_arc']:
                self._listToFile(self.fileList[strg], "/tmp/" + self.uniqueId + "evict_arc.txt")
                self._scpFile("/tmp/" + self.uniqueId + "evict_arc.txt", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'] + ":" + self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "evict_arc.txt")
                procsToWait.append(self._ssh(["ssh", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/afmExec.sh", "evict", self.config['gpfs']['gpfs_fs'], self.config['gpfs']['arc_fset'], self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "evict_arc.txt", self.config['general']['content_file'], self.config['gpfs']['gpfs_fs_path']], False))

        for proc in procsToWait:
            os.waitpid(proc.pid, 0)

        self.status = "done"
        self._printStatus()

    def migrateArchive(self):
        if 'Archive' in self.fileList and len(self.fileList['Archive']) > 0:
            if self.nextAction == "prefetch":
                print("Next Action is prefetch which does not fit the migrate to tape process.")
                sys.exit(-1)
                
            # need to scp and execute
            self._listToFile(self.fileList['Archive'], "/tmp/" + self.uniqueId + "migrate.txt")
            self._scpFile("/tmp/" + self.uniqueId + "migrate.txt", self.config['archive']['archive_user'] + "@" + self.config['archive']['archive_server'] + ":" + self.config['archive']['archive_home_path'] + self.uniqueId + "migrate.txt")
            self._ssh(["ssh", "-t", self.config['archive']['archive_user'] + "@" + self.config['archive']['archive_server'], self.config['archive']['archive_sudo'] + " /opt/ibm/ltfsee/bin/eeadm", "migrate", self.config['archive']['archive_home_path'] + self.uniqueId + "migrate.txt", "-p", "pool1"])
        self._printStatus()

    def cleanup(self):
        self.fileList.clear()
        self.lastQuery = ""
        self.nextAction = ""
        self.status = ""
       
        for filePath in glob.glob('/tmp/' + self.uniqueId + '*.txt'):
            os.remove(filePath)
        self._ssh(["ssh", self.config['archive']['archive_user'] + "@" + self.config['archive']['archive_server'], "rm", "-f", self.config['archive']['archive_home_path'] + self.uniqueId + "*.txt"])
        self._ssh(["ssh", self.config['gpfs']['ess3k_mgmt_user'] + "@" + self.config['gpfs']['ess3k_mgmt_server'], "rm", "-f", self.config['gpfs']['ess3k_mgmt_home_path'] + "DAAA/" + self.uniqueId + "*.txt"])
        self._printStatus()
