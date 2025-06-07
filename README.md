# nfs-automount-script
NIM Server NFS Auto-Mount Script (AIX)

This script helps automatically mount NFS shares from NIM servers on an AIX system. It first checks if the mount point is already in use and skips the process if it is. Before trying to mount, it checks if the NIM servers are reachable by testing network ports 111 and 2049. If one server doesn't work, it moves on to the next. 
