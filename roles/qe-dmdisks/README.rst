================
 QE-DM-disks
================

This role creates Device Mapper disk based on real device and 
selected table format (e.g "error", "zero", "delay", "flakey").

This role is first role in row for testing disk failures.


See Also:

 * https://www.kernel.org/doc/Documentation/device-mapper/dm-flakey.txt
 * https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/logical_volume_manager_administration/device_mapper
 * https://mbroz.fedorapeople.org/talks/DeviceMapperBasics/dm.pdf
 * https://stackoverflow.com/questions/31806244/simulating-bad-sectors-in-linux
 
 If there is need to do scsi disk with failure, see:

 * http://sg.danny.cz/sg/sdebug26.html
 * https://www.certdepot.net/rhel7-configure-iscsi-target-initiator-persistently/
