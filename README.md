# yum_update_non_heat

There are two files here: one is the script which will be executed on the
node itself, and the other is the 'main' script which attempts to introduce
some kind of update workflow. The main script takes one string parameter to
determine the node(s) the script will be delivered to and then executed on.

The param is used to grep the output of nova list and a list of nodes can be
specified like:

    bash tripleo_upgrade_non_heat_main.sh  "compute-0 compute-1"

To match *all* computes you can do:

    bash tripleo_upgrade_non_heat_main.sh  "compute"

The update script itself does nothing at present, so this should be safe enough
to run against your setup; NOTE however the nodes are nova rebooted at the end
