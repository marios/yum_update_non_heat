#!/bin/bash

SCRIPT_PATH=$HOME
YUM_UPDATE_SCRIPT=tripleo_upgrade_yum_update_non_heat.sh
DEBUG=1
REBOOT_SLEEP_TIME=10

function log {
    if [[ $DEBUG == 1 ]]; then
        echo "UPDATE-SCRIPT `date`:>> $1"
    fi
}

function source_stackrc {
    log "Attempting to source $HOME/stackrc"
    source $HOME/stackrc
}

function confirm_script {
    node_ip=$i
    results=$(ssh heat-admin@$node_ip "sudo ls -l /root/$YUM_UPDATE_SCRIPT")
    permissions=$(echo $results | awk '{print $1}')
    if ! [[ "-rwxr--r--," =~ $permissions ]]; then
        log "ERROR"
    else
        log "OK update script delivered to $node_ip, ls -l: $results"
    fi
}

function deliver_script {
    node_ip=$1
    scp ~/$YUM_UPDATE_SCRIPT heat-admin@$node_ip:/home/heat-admin/$YUM_UPDATE_SCRIPT
    ssh heat-admin@$node_ip "sudo cp /home/heat-admin/$YUM_UPDATE_SCRIPT \
                                     /root/$YUM_UPDATE_SCRIPT ; \
                             sudo chmod 744 /root/$YUM_UPDATE_SCRIPT ; "
    check_file=$(ssh heat-admin@$node_ip "sudo ls -l /root/$YUM_UPDATE_SCRIPT")

}

function run_script {
    node_ip=$i
    log "Trying to run update script for $node_ip"
    ssh heat-admin@$node_ip "sudo /bin/bash /root/$YUM_UPDATE_SCRIPT"
}

function nova_reboot {
    node_ip=$i
    uuid=$(nova list | grep $node_ip | awk '{print $2}')
    log "Starting nova reboot on node $uuid with IP $node_ip"
    nova reboot $uuid
    log "Sleeping for $REBOOT_SLEEP_TIME seconds to allow reboot"
    sleep $REBOOT_SLEEP_TIME;
    active=$(nova list | grep $uuid | grep "ACTIVE")
    while [[ -z $active ]]; do
        log "Node $uuid not yet active, sleeping for $REBOOT_SLEEP_TIME seconds to allow reboot"
        sleep $REBOOT_SLEEP_TIME;
        active=$(nova list | grep $uuid | grep "ACTIVE")
    done
    log "Successfully rebooted node $uuid: $active"
}

source_stackrc
update_nodes=$1
grep_match=$(echo $update_nodes | sed 's/ /\\\|/g')
node_ips=`nova list | grep $grep_match | awk '{print $12}' | tr "ctlplane=" "\n"`

#deliver the update script
for i in $node_ips; do
    log "Copying script to $i"
    deliver_script $i
    log "Confirming script is on $i"
    confirm_script $i
done

log "Starting update"
for i in $node_ips; do
    uuid=$(nova list | grep $node_ip | awk '{print $2}')
    log "About to update node with uuid $uuid and IP $i. Enter 'yes' to continue (anything else to skip to the next node):"
    read continue_update
    if [[ $continue_update == "yes" ]]; then
        run_script $i
        nova_reboot $i
    else
        log "Skipping node $uuid on user input"
    fi
    log "Node $uuid ($i) updated"
done


