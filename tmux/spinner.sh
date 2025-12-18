#!/bin/bash
SYMBOLS=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
SYMBOLS_LENGTH=${#SYMBOLS[@]}

TIMER_FILE=/tmp/spinner_timer

start_timer() {
    local duration=$1
    echo $(date -d +$duration +%s) > "$TIMER_FILE"
}


display_timer() {
    if [[ ! -f $TIMER_FILE ]]; then
        echo ""
        return
    fi

    TS_TARGET=$(cat ${TIMER_FILE})
    ts_now=$(date +%s)

    remain=$((TS_TARGET - ts_now))
    (( remain < 0 )) && remain=0

    remain_hh=$((remain / 3600))
    remain_mm=$(( (remain % 3600) / 60 ))
    remain_ss=$(( remain % 60 ))
    idx=$(( ts_now % SYMBOLS_LENGTH ))
    if [[ $remain -eq 0 ]]; then
        rm ${TIMER_FILE}
        tmux display-message "Timer done"
    else 
        echo "#[fg=yellow]${SYMBOLS[$idx]} $(printf "%02d:%02d:%02d" "$remain_hh" "$remain_mm" "$remain_ss")"
    fi
}

if [[ -z $1 ]]; then
    display_timer 
else
    start_timer $1
fi

