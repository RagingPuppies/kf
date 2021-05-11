function describe_topic_config {
    bootstrap_server="$1"
    topic_name="$2"
    /etc/kafka/bin/kafka-configs.sh --describe --all \
      --bootstrap-server="${bootstrap_server}:9092" \
      --topic ${topic_name} | awk 'BEGIN{IFS="=";IRS=" "} /^[ ]*retention.ms/{print $1}'
}

function all_topics_list {
bootstrap_server="$1"
/etc/kafka/bin/kafka-topics.sh --list --zookeeper "${bootstrap_server}:2181"
}

function update_retention {
    topic_name="$1"
	config_value="$2"
	bootstrap_server="$3"
    config_name="retention.ms"
    ./bin/kafka-configs.sh --alter \
      --add-config ${config_name}=${config_value} \
      --bootstrap-server=$bootstrap_server:9092 \
      --topic ${topic_name}
}

# Help section
while getopts ":h" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "    kf -h                      Display this help message."
      echo "    kf <method> <option> <tag>"
      echo "Example:"
      echo "    kf apply retention -t all -s A_kafka1 -r 300000000"
      echo "    kf get retention -t test -s A_kafka1"
      echo "Methods:"
      echo "    get, apply"
      echo "Options:"
      echo "    retention"
      echo "Tags:"
      echo "    -t <topic_name> \ All"
      echo "    -s <bootstrap_server>"
      echo "    -r <retention (int)>"
      exit 0
      ;;
   \? )  echo "Invalid Option: -$OPTARG" 1>&2; exit 1 ;;
  esac
done

shift $((OPTIND -1))
# Method Section
subcommand=$1; shift

case "$subcommand" in
	get)
		option=$1; shift

		case "$option" in
			
			retention ) # Process 'get retention' tags
			
				while getopts "s:t:" opt; do

					case ${opt} in
						t  ) topic=$OPTARG  ;;
						s  ) bootstrap_server=$OPTARG ;;
						\? ) echo "Invalid Option: -$OPTARG" 1>&2; exit 1 ;;
						:  ) echo "Invalid Option: -$OPTARG requires an argument" 1>&2; exit 1;;
					esac

				done

				if [[ $topic == "all" ]] 
				then
					topic_list=$(all_topics_list)
					for t in $topic_list; do
						echo "Getting retention for: $t"
						describe_topic_config $bootstrap_server $t
					done
				else
					describe_topic_config $bootstrap_server $topic
				fi
			;;

		esac
		;;
	apply)
		option=$1; shift

		case "$option" in
			
			retention ) # Process 'apply retention' tags
			
				while getopts "s:t:r:" opt; do

					case ${opt} in
						t  ) topic=$OPTARG  ;;
						s  ) bootstrap_server=$OPTARG ;;
						r  ) ret=$OPTARG ;;
						\? ) echo "Invalid Option: -$OPTARG" 1>&2; exit 1 ;;
						:  ) echo "Invalid Option: -$OPTARG requires an argument" 1>&2; exit 1;;
					esac

				done

				if [[ $topic == "all" ]] 
				then
					topic_list=$(all_topics_list)
					for t in $topic_list; do
						echo "Setting retention for: $t"
						update_retention $t $ret $bootstrap_server
					done
				else
					update_retention $topic $ret $bootstrap_server
				fi
			;;

		esac
		;;
esac
