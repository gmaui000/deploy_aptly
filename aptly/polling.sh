#!/bin/bash

function find_target_version() {
    search_dir=$1
    pattern="voyance_[0-9].[0-9].[0-9]_amd64.deb"
    files=$(find "$search_dir" -name "$pattern")
    sorted=$(echo "$files" | sort -t_ -k2 -k3 -k4)
    target=$(echo "$sorted" | tail -n 1)

    echo "$target"
}

target=$(find_target_version /aptly/repo)
if [ -z $target ]; then
    version=""
else
    version=$(echo "$target" | cut -d _ -f 2)
fi

inotifywait -m /aptly/repo -e create -e delete |
    while read path action file; do
        if [[ "$action" == "CREATE" ]]; then
            # do something when a file is created
    	    if echo "$file" | grep "^voyance_0.*_amd64.deb$"; then
	        new_version=$(echo "$file" | cut -d _ -f 2)
	        if [[ $(echo -e "$version\n$new_version" | sort -V | tail -n1) == "$new_version" ]]; then
                    file_size=$(du -b $path/$file | awk '{print $1}')
                    while true; do
                        sleep 2
		        new_size=$(du -b $path/$file | awk '{print $1}')
                        if [[ "$new_size" -eq "$file_size" ]]; then
                            echo "File transfer completed: $path/$file"
		            break
		        else
		            file_size=$new_size
                        fi
                    done 

		    echo "new file:$file version:$new_version add."
		    if ! aptly repo list | grep "^voyance$"; then
                        echo "Repo 'voyance' not found, creating..."
                        aptly repo create voyance
                    fi
                    aptly repo add voyance /aptly/repo/$file
                    aptly snapshot create voyance-$new_version-snapshot from repo voyance
                    aptly publish drop focal voyance
                    aptly publish snapshot -batch=true  -distribution=$APT_DISTRIBUTION -passphrase="$GPG_PASSPHRASE" voyance-$new_version-snapshot voyance
		    version=$new_version
                    if pgrep -f "aptly serve" > /dev/null; then
                        echo "aptly process already running"
                    else
                        echo "aptly process not found, starting it"
                        aptly serve &
                    fi
                fi
            fi
        elif [[ "$action" == "DELETE" ]]; then
            echo "File $file was deleted from $path"
            # do something when a file is deleted
    	    if echo "$file" | grep "^voyance_0.*_amd64.deb$"; then
		del_version=$(echo "$file" | cut -d _ -f 2)
                if [[ "$del_version" == "$version" ]]; then
		     echo "warning current version has been delted."
		fi
            fi
        fi
    done
