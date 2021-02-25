#!/bin/bash
docker run --rm -d -t --expose 5064 --expose 5065 whitegr/facet-dev /bin/bash -ilc /root/run-swdev.sh