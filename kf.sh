DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/validations.sh"
. "$DIR/drain.sh"
. "$DIR/general.sh"
. "$DIR/balance.sh"


# help section
while getopts ":hu:" opt; do
  case ${opt} in
    u ) user=${OPTARG} ;;
   \? )  echo "Invalid Option: -$OPTARG" 1>&2; exit 1 ;;
    h | *)
      echo "Methods:
       drain <broker_number> <partition_concurrency(default:5)>   | Will decomission a broker
       balance <partition_concurrency(default:5)>                 | Will balance all partitions in the cluster
Tags:
       -u                                                         | Set the user for email notification (default: datainfra)

Example:
       kf -u tsetty balance 2                                     | Will balance the cluster with 2 paritions max moving at the same time, at the end will send email to tsetty."

      exit 0
      ;;
  esac
done

# Validations
validations


shift $((OPTIND -1))
# Method Section
subcommand=$1; shift

case "$subcommand" in
	drain)
    
        option=$1; shift
        broker=$option

        option=$1; shift
        partitions=$option

        validate_args $broker
        drain $broker $partitions $user

		;;

	balance)
		option=$1; shift
        partitions=$option

        balance_partitions $partitions $user
        balance_leaders
    

		;;
esac