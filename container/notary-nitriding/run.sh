#!/bin/bash -e
# Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.

readonly EIF_PATH="/home/notary-server.eif"
readonly ENCLAVE_CPU_COUNT=2
readonly ENCLAVE_MEMORY_SIZE=4096
readonly NE_ALLOCATOR_SPEC_PATH="/etc/nitro_enclaves/allocator.yaml"

main() {
    sed -i "s/cpu_count:.*/cpu_count: $ENCLAVE_CPU_COUNT/g" $NE_ALLOCATOR_SPEC_PATH
    sed -i "s/memory_mib:.*/memory_mib: $ENCLAVE_MEMORY_SIZE/g" $NE_ALLOCATOR_SPEC_PATH
    cat /etc/nitro_enclaves/allocator.yaml
    nitro-cli describe-enclaves
    nitro-cli run-enclave --cpu-count $ENCLAVE_CPU_COUNT --memory $ENCLAVE_MEMORY_SIZE \
        --eif-path $EIF_PATH

    local enclave_id=$(nitro-cli describe-enclaves | jq -r ".[0].EnclaveID")
    echo "-------------------------------"
    echo "Enclave ID is $enclave_id"
    echo "-------------------------------"

    # nitro-cli console --enclave-id $enclave_id # blocking call.
    pkill -f gvproxy || true
    gvproxy -listen vsock://:1024 -listen unix:///tmp/network.sock &
    sleep 2
    curl   --unix-socket /tmp/network.sock   http:/unix/services/forwarder/expose   -X POST   -d '{"local":":444","remote":"192.168.127.2:444"}'
    curl   --unix-socket /tmp/network.sock   http:/unix/services/forwarder/expose   -X POST   -d '{"local":":443","remote":"192.168.127.2:443"}'
    
    while [[ $(nitro-cli describe-enclaves) != "[]" ]]; do
        echo "Enclave is still running. Waiting..."
        sleep 10
    done

    echo "Enclave has terminated."
}

main
