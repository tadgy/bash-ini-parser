#!@BASH_PATH@
# Author: Jack L. Frost <fbt@fleshless.org>
# Licensed under the Internet Software Consortium (ISC) license.
# See LICENSE for its text.

_self="${0##*/}"

err() { printf '%s\n' "$*" >&2; }

debug() {
	(( $flag_debug )) && { printf '%s\n' "DEBUG: $*"; }
}

usage() {
	while read; do printf '%s\n' "$REPLY"; done <<- EOF
		Usage: $_self [flags]
		Flags:
		        -h|--help            Show this message.
		        -c|--config <file>   Use a config specified by <file>.
		        -d|--debug           Enable debug messages.
	EOF
}

cfg_load() {
	declare section line key value
	declare -g -A cfg

	mapfile -t config < "$1"

	for line in "${config[@]}"; do
		if [[ "$line" =~ ^\[.+\] ]]; then
			section="${line//[\[\]]/}"

			case "$section" in
				main) :;;
				*) ifaces+=( "${line//[\[\]]/}" );;
			esac
		elif [[ "$line" =~ ^('#'|\s+?$) ]]; then
			:
		else
			IFS='=' read -r key value <<< "$line"

			if ! [[ "$section" ]]; then
				err "Key $key does not belong to a section!"
				return 1
			fi

			if [[ "$key" ]]; then
				if ! [[ "$value" ]]; then
					value=1
				fi

				if [[ ${cfg[${section}_$key]} ]]; then
					declare -g cfg["${section}_$key"]="${cfg[${section}_$key]}#${value}"
				else
					declare -g cfg["${section}_$key"]="$value"
				fi
			fi
		fi
	done
}

net_up() {
	for iface in "${ifaces[@]}"; do
		# Prepare the interface
		if [[ "${cfg[${iface}_preup]}" ]]; then
			${cfg[${iface}_preup]}
		fi

		# Bring the interface up
		if [[ "${cfg[${iface}_up]}" ]]; then
			${cfg[${iface}_up]}
		else
			if [[ "${cfg[${iface}_vlan_dev]}" ]]; then
				ip link add link "${cfg[${iface}_vlan_dev]}" name "$iface" type vlan id "${cfg[${iface}_vlan_id]}"
			fi

			ip link set "$iface" up
		fi

		# Add IPs
		if [[ "${cfg[${iface}_ip]}" ]]; then
			IFS='#' read -r -a ips <<< "${cfg[${iface}_ip]}"

			for a in "${ips[@]}"; do
				ip addr add "$a" dev "$iface"
			done
		fi

		# Configure the interface with dhcp if needed
		if [[ "${cfg[${iface}_dhcp]}" ]]; then
			${cfg[main_dhcp_up]} "$iface"
		fi

		# Add routes
		if [[ "${cfg[${iface}_route]}" ]]; then
			IFS='#' read -r -a routes <<< "${cfg[${iface}_route]}"

			for r in "${routes[@]}"; do
				read -r net gw <<< "$r"

				ip route add "$net" via "$gw"
			done
		fi

		if [[ "${cfg[${iface}_postup]}" ]]; then
			${cfg[${iface}_up]}
		fi
	done
}

net_down() {
	for iface in "${ifaces[@]}"; do
		# Prepare the interface
		if [[ "${cfg[${iface}_predown]}" ]]; then
			${cfg[${iface}_predown]}
		fi

		# Remove routes
		if [[ "${cfg[${iface}_route]}" ]]; then
			IFS='#' read -r -a routes <<< "${cfg[${iface}_route]}"

			for r in "${routes[@]}"; do
				read -r net gw <<< "$r"

				ip route del "$net" via "$gw"
			done
		fi

		# Stop dhcpcd
		if [[ "${cfg[${iface}_dhcp]}" ]]; then
			${cfg[main_dhcp_down]} "$iface"
		fi

		# Remove IPs
		if [[ "${cfg[${iface}_ip]}" ]]; then
			IFS='#' read -r -a ips <<< "${cfg[${iface}_ip]}"

			for a in "${ips[@]}"; do
				ip addr del "$a" dev "$iface"
			done
		fi

		# Bring the interface down
		if [[ "${cfg[${iface}_down]}" ]]; then
			${cfg[${iface}_down]}
		else
			ip link set "$iface" down
			
			if [[ "${cfg[${iface}_vlan_dev]}" ]]; then
				ip link del "$iface"
			fi
		fi

		if [[ "${cfg[${iface}_postdown]}" ]]; then
			${cfg[${iface}_postdown]}
		fi
	done
}

set_argv() {
	declare arg opt c
	declare -g argv

	while (( $# )); do
		unset -v arg opt c

		case "$1" in
			(--) argv+=( "$1" ); break;;

			(--*)
				IFS='=' read arg opt <<< "$1"
				argv+=( "$arg" )

				[[ "$opt" ]] && {
					argv+=( "$opt" )
				}
			;;

			(-*)
				while read -n1 c
				do
					case "$c" in
						-|'') :;;
						*) argv+=( "-$c" );;
					esac
				done <<< "$1"
			;;

			(*) argv+=( "$1" );;
		esac
		shift
	done
}

main() {
	while (( $# )); do
		case "$1" in
			-h|--help) usage; return 0;;
			-d|--debug)
				flag_debug=1
				debug "Debug flag set."
			;;
			-c|--config) cfg_file="$2"; shift;;

			--) shift; break;;
			-*)
				err "Unknown key: $1"
				usage
				return 1
			;;
			*) break;;
		esac
		shift
	done

	if ! [[ "$cfg_file" ]]; then
		cfg_file='@CONFDIR@/networking'
	fi

	cfg_load "$cfg_file" || {
		return "$?"
	}

	action=${1:-"up"}

	case "$action" in
		up) net_up;;
		down) net_down;;
	esac
}

set_argv "$@"
main "${argv[@]}"
