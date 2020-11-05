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

import DAAA

daaa = DAAA.DAAA('DAAA.ini')
daaa.getConfig()
daaa.searchDiscover(["front=1", "center=1", "bicycle>=900", "bicycle<=1000"], "prefetch")
daaa.getFileLists("['NFS', 'Spectrum Scale', 'IBM COS']")
daaa.recallArchive()
daaa.cacheDataIn()
daaa.runAnalytics()
daaa.searchDiscover(tagsToSearchArr="", action="evict", arconly=True)
daaa.evictDataOut()
daaa.migrateArchive()
daaa.cleanup()
