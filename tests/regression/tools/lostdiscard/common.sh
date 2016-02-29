#!/bin/bash

function enable_channel_small()
{
	mode=$1
	sess_name=$2
	channel_name=$3
	domain=$4

	$TESTDIR/../src/bin/lttng/$LTTNG_BIN enable-channel $domain $channel_name \
		-s $sess_name --subbuf-size $(getconf PAGE_SIZE) \
		--num-subbuf 8 $mode
	ok $? "Enable channel $channel_name per PID for session $sess_name"
}

function validate_discarded()
{
	local trace_path=$1

	which $BABELTRACE_BIN >/dev/null
	if [ $? -ne 0 ]; then
	    skip 0 "Babeltrace binary not found. Skipping trace validation"
	fi

	OLDIFS=$IFS
	discarded=$(echo $($BABELTRACE_BIN $trace_path 2>&1 >/dev/null | grep discarded | cut -d" " -f4 | tr "\n" "+"| sed "s/.$//") | bc)
	return $discarded
}

function check_babeltrace_version()
{
	which $BABELTRACE_BIN >/dev/null
	if [ $? -ne 0 ]; then
	    skip 0 "Babeltrace binary not found. Skipping trace validation"
	    return 0
	fi

	major=$($BABELTRACE_BIN | head -1|cut -d' ' -f6 | cut -d'.' -f 1)
	minor=$($BABELTRACE_BIN | head -1|cut -d' ' -f6 | cut -d'.' -f 2)

	if test $major -gt 2; then
		return 0;
	fi
	if test $major = 1; then
		if test $minor -lt 3; then
			return -1
		fi
	fi
	return 0
}

function validate_lost()
{
	local trace_path=$1

	which $BABELTRACE_BIN >/dev/null
	if [ $? -ne 0 ]; then
	    skip 0 "Babeltrace binary not found. Skipping trace validation"
	fi

	OLDIFS=$IFS
	lost=$(echo $($BABELTRACE_BIN $trace_path 2>&1 >/dev/null | grep lost | cut -d" " -f4 | tr "\n" "+"| sed "s/.$//") | bc)
	return $lost
}

function lttng_list_discarded()
{
	sess_name=$1
	discarded=$($TESTDIR/../src/bin/lttng/$LTTNG_BIN list $sess_name | grep discarded | cut -d':' -f2 | sed 's/ //g')
	return $discarded
}

function lttng_list_lost()
{
	sess_name=$1
	lost=$($TESTDIR/../src/bin/lttng/$LTTNG_BIN list $sess_name | grep lost | cut -d':' -f2 | sed 's/ //g')
	return $lost
}
