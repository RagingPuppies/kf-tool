# kf yet another kafka tool
This tool utilize kafka-utils and other useful tools to fully automate Devops tasks. 
## usage
```
Methods:
       drain <broker_number> <partition_concurrency(default:5)>   | Will decomission a broker
       balance <partition_concurrency(default:5)>                 | Will balance all partitions in the cluster
Tags:
       -u                                                         | Set the user for email notification

Example:
       kf -u tsetty balance 2                                     | Will balance the cluster with 2 paritions max moving at the same time, at the end will send email to tsetty.
```

When activating the tool it will create a file in /tmp/max-move-patitions that can be altered to run slower\quicker without breaking the script.
At the end if the run you'll get a notification to you email that the job was finished.


## Dev
If you'd like to contribue there's a dockerfile and requirements file along-side the code, so you can spin up a container with the required configurations.

## Debug
set environment variable as follow to see debug messages:
`export KF_DEBUG=TRUE`