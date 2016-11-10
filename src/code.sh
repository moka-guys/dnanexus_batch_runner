#!/bin/bash

set +e -x
#set +e

# batch_runner 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See http://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {


    job_id=$DX_JOB_ID
    workspace=$DX_WORKSPACE_ID
    unset DX_WORKSPACE_ID
    project=$DX_PROJECT_CONTEXT_ID
    dx select "$project"    
    
    if [ -z "$token" ]
    then
        folder="Results"
    else
        echo "Value of token: '$token'"
        unset DX_JOB_ID
        DX_SECURITY_CONTEXT='{"auth_token": "'$token'", "auth_token_type": "Bearer"}'
        folder="Results"
    fi
    
    echo "Value of workflow: '$workflow'"
    echo "Value of input_pattern: '$input_pattern'"
    echo "Value of input_identifier: '$input_identifier'"
    echo "Value of replace_identifier: '$replace_identifier'"
    echo "Value of input_class: '$input_class'"
    
    
    log="Batch_Log_"${workflow//\//-}

    executable=`dx describe $workflow --json | jq -r .stages[0].executable`
    app_name=`dx describe $executable --json | jq -r .id`

    if ! $paired
	then
	input_identifier=$input_pattern
	fi

    if [ -n `dx find data --class "$input_class" --name "$input_pattern" --project $DX_PROJECT_CONTEXT_ID --folder /Inputs --brief` ]
	then
	dx-jobutil-report-error "Could not find any inputs which matched the input pattern "$input_pattern
    fi

    index=0
    for file in `dx find data --class "$input_class" --name "$input_pattern" --project $DX_PROJECT_CONTEXT_ID --folder /Inputs --brief`
    do
	name=`dx describe "$file" --name`
	if [[ "$name" == *$input_identifier* ]]
	    then
	    name2=${name/"$input_identifier"/"$replace_identifier"}
    
	    f1_id=`dx find data --name "$name" --folder /Inputs --brief`
	    f2_id=`dx find data --name "$name2" --folder /Inputs --brief`
    
            #workflow_id=`dx find data --class workflow --name "$workflow" --brief`
	    workflow_id=`dx find data --name "$workflow" --brief`
	    if [ -z "$workflow_id" ]
		then
		dx-jobutil-report-error "Could not find a workflow with name "$workflow
	    fi

    
            python /get_workflow_data.py "$file" "$workflow_id" "$app_name" >> run.txt
    
            lines=`wc -l inputs_stats.txt`

            input1=`head -1 inputs_stats.txt | tail -1`
            input2=`head -2 inputs_stats.txt | tail -1`
            
            if [ "$lines" == "1 inputs_stats.txt" ] || ! $paired
	    then
		if $paired
		then
		    set -e
		    dx-jobutil-report-error "Expected paired data but could not find a match for "$name" (looked for "$name2")"
		    return
		fi
		echo dx run "$workflow_id" -i0."$input1"="$f1_id" --folder "$folder" -y --brief >> $log
		#eval dx run "$workflow_id" -i0."$input1"="$f1_id" --folder "$folder" -y --brief >> "$log"
                job_ids[$index]=`dx run "$workflow_id" -i0."$input1"="$f1_id" --folder "$folder" -y --brief`
                index=$((index+1))
            fi
            if [ "$lines" == "2 inputs_stats.txt" ] && $paired
            then
		echo dx run "$workflow_id" -i0."$input1"="$f1_id" --folder "$folder" -i0."$input2"="$f2_id" -y --brief >> "$log"
		#eval dx run "$workflow_id" -i0."$input1"="$f1_id" --folder "$folder" -i0."$input2"="$f2_id" -y --brief >> "$log"
		job_ids[$index]=`dx run "$workflow_id" -i0."$input1"="$f1_id" --folder "$folder" -i0."$input2"="$f2_id" -y --brief`
                index=$((index+1))
            fi
	fi
    done
    
    DX_WORKSPACE_ID=$workspace
    DX_JOB_ID=$job_id
    
    for (( i=0; i<${#job_ids[@]}; i++ ));
    do
      dx wait ${job_ids[$i]}
    done

    created_folders=`dx ls $DX_WORKSPACE_ID --folder`
    # If the Results folder exist, adding it into the project and suffixing it with data and time (UT)
    if [ "$created_folders" == "${folder}/" ]; then
        dx cp $DX_WORKSPACE_ID:Results $DX_PROJECT_CONTEXT_ID:Results_$(date +"%m_%d_%y-%T" | sed 's/:/-/g')_UT       
    else
        echo -e "No results have been generated..."
    fi
    #sleep 3000
    #log=$(dx upload "$log" -o "$project":Batch_Log/"$log" -p --brief)
    #dx-jobutil-add-output log "$log" --class=file
}
