function drain_broker_cycle {
    broker_id="$1"
    max_partition_movment="$2"
    /usr/local/bin/kafka-cluster-manager \
    --cluster-type generic \
    --cluster-name this_cluster \
    --apply --no-confirm decommission $broker_id \
    --max-partition-movements $max_partition_movment 2>/dev/null
}

function check_remaining_partitions {
    broker_id="$1"
    partitions_left_to_migrate=$(/usr/local/bin/kafka-cluster-manager \
                                --cluster-type generic \
                                --cluster-name this_cluster stats 2>/dev/null| grep $broker_id | awk 'NR==1{print $3}')

  echo $partitions_left_to_migrate

}


function drain {
    
    broker=$1
    partitions=$2
    user=$3
    sendCL "Drain Kafka partitions on from ${HOSTNAME} on ${broker}" $user
    if [[ "$partitions" -eq "" ]]
    then
      partitions=5
    fi

    echo $partitions > /tmp/max-partition-movment

    total_partitions=$(check_remaining_partitions $broker)
    partitions_left_to_migrate=$(check_remaining_partitions $broker)
    
    COUNTER=0
    echo $partitions_left_to_migrate
    while [ $partitions_left_to_migrate -ne 0 ] ;do
            progress_bar $total_partitions $partitions_left_to_migrate "Drain"
            while active_task ;do
                sleep 1
            done

            # Check if max partition movement changed
            current_max_partitions=$(cat /tmp/max-partition-movment)
            drain_broker_cycle $broker $current_max_partitions
            
            while active_task ;do
                sleep 2
            done

            partitions_left_to_migrate=$(check_remaining_partitions $broker)


        done
    #clear
    echo "There are 0 partitions on $broker !"
    sendMail "KF Tool Notification - Drain finished." "Seemes like a Drain jon for $broker was finished, $total_partitions partitions were drained." $user
    rm -f /tmp/max-partition-movment
}