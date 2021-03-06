#!/bin/sh

# Copyright (c) 2015, Plume Design Inc. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#    3. Neither the name of the Plume Design Inc. nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Plume Design Inc. BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


if [ -e "/tmp/fut_set_env.sh" ]; then
    source /tmp/fut_set_env.sh
else
    source /tmp/fut-base/shell/config/default_shell.sh
fi
source "${FUT_TOPDIR}/shell/lib/unit_lib.sh"
source "${FUT_TOPDIR}/shell/lib/onbrd_lib.sh"
source "${LIB_OVERRIDE_FILE}"

usage="
$(basename "$0") [-h] \$1

where options are:
    -h  show this help message

where arguments are:
    cert_file=\$1 -- used as file to check - (string)(required)

this script is dependent on following:
    - running DM manager

example of usage:
   /tmp/fut-base/shell/onbrd/$(basename "$0") ca_cert
   /tmp/fut-base/shell/onbrd/$(basename "$0") certificate
   /tmp/fut-base/shell/onbrd/$(basename "$0") private_key
"

while getopts h option; do
    case "$option" in
        h)
            echo "$usage"
            exit 1
            ;;
    esac
done

if [ $# -ne 1 ]; then
    echo 1>&2 "$0: incorrect number of input arguments"
    echo "$usage"
    exit 2
fi

cert_file=$1
tc_name="onbrd/$(basename "$0")"
cert_file_path=$(get_ovsdb_entry_value SSL "$cert_file")

log "$tc_name: ONBRD Verify file exists"
[ -e "$cert_file_path" ] &&
    log "$tc_name: SUCCESS: file is valid - $cert_file_path" ||
    raise "FAIL: file is missing - $cert_file_path" -l "$tc_name" -tc

log "$tc_name: ONBRD Verify file is not empty"
[ -s "$cert_file_path" ] &&
    log "$tc_name: SUCCESS: file is not empty - $cert_file_path" ||
    raise "FAIL: file is empty - $cert_file_path" -l "$tc_name" -tc

pass
