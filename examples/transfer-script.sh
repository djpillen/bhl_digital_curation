#!/bin/bash
cd /usr/lib/automation-tools
/usr/share/bhl_digital_curation/virtualenvs/venv/bin/python -m transfers.transfer --transfer_source TRANSFER_SOURCE_NAME --depth N -c /vagrant/automation-tools/configs/config.conf
