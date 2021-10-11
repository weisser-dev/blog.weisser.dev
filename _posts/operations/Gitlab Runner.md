
#Running like a Pipeline
-docker images kopieren in cache und neu laden - damit umgeht man traffic probleme bei zu kleinen nodes / bandbreiten beschränkungen
- keine highmem maschinen nehmen
- nicht primeeble wenn man ein job länger dauert, sonst könnten die maschinen einen error code werfen und die runner killen
- gitlab alpine hat öfters mal probleme mit auth gegen gitlab, deshalb lieber ubuntu runner nehmen
- mehr build steps aus den pipelines in docker images nehmen und weniger steps in der pipeline -> dadurch sind die runner nicht so sehr ausgelastet (bei mandantenfähig von features bspw. wichtig)
- probieren welche runner config passt. wenn man große dockerfiles baut und da logik verwendet kann der runner schonmal etwas mehr speicher benötigen - daher klein anfangen und schauen ab wann er nicht mehr failed + puffer 

vorteil cache:
schnell verfügbar

> Written with [StackEdit](https://stackedit.io/).
