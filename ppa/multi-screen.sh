#!/bin/bash

# 循环尝试120s
for i in $(seq 1 60); do
    screen=$(xrandr | grep -E 'connected 1920x1080' | awk '{print $1}')
    if [ -n "$screen" ]; then
        echo "screen: $screen"
        input=$(xinput | grep -E 'eGalax Inc. eGalaxTouch' | awk -F '[=\t]+' '{print $3}')
        if [ -n "$input" ]; then
            echo "input: $input"
            xinput map-to-output $input $screen
	    result=$(xinput --list-props $input | grep -E 'Coordinate Transformation Matrix' | awk '{print $7}')
	    result=${result%,}
            if [ $(echo "$result == 0.0" | bc -l) -eq 1 ]; then
                echo "xinput executed failed."
            else
    	    	echo "xinput executed successfully."
            fi
	    exit 0
        fi
    fi
    sleep 2
done

