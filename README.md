# yum_update_non_heat

Quickstart:

    git clone https://github.com/marios/yum_update_non_heat.git
    cd yum_update_non_heat/
    chmod 744 tripleo_upgrade_non_heat_main.sh
    SCRIPT_PATH=`pwd` ./tripleo_upgrade_non_heat_main.sh "compute-0 compute-1"


There are two files here: one is the script which will be executed on the
overcloud node itself, called `tripleo_upgrade_yum_update_non_heat.sh` and the other is
the 'main' script the operator runs from the undercloud called `tripleo_upgrade_non_heat_main.sh`.
The main script takes one string parameter to determine the node(s) the script
will be delivered to and then executed on.

The param is used to grep the output of nova list and a list of nodes can be
specified like:

    bash tripleo_upgrade_non_heat_main.sh  "compute-0 compute-1"

To match *all* computes you can do:

    bash tripleo_upgrade_non_heat_main.sh  "compute"

The update script itself does nothing at present, so this should be safe enough
to run against your setup; **NOTE** however the nodes are nova rebooted at the end


