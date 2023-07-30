#! /usr/bin/fish 

function help_msg 
	printf "\n"
	echo "Usage: ero <filePath> [options]" 
	printf "\n"
	echo "Options:"
	echo "    --testId, -t          Specifies which testcase to use as input [number]"
	echo "    --help, -h            Show help                               [boolean]"
end

function unrecognized
	echo "Try 'ero --help' for more information"
	exit 1
end

argparse --name=ero 'h/help' 't/testId=!_validate_int --min 0' -- $argv; or unrecognized 

# If the help page is needed
if set -q _flag_help
	help_msg
	return 0 
end

set -l filename (basename $argv[1] 2>/dev/null)
set -l name (basename $argv[1] .cpp 2>/dev/null)
set -l name_list (string split . $argv[1] 2>/dev/null)
set -l file_ext $name_list[-1]
set -l dir_with_name (dirname $argv[1] 2>/dev/null)/$name

if test (count $argv) -eq 0
	help_msg
	printf "\n"
	echo "Missing <filePath> in arguments"
	return 1

else if not test "$file_ext" = "cpp"
	help_msg
	printf "\n"
	echo "Language not supported"
	return 1

else if test (count $argv) -gt 1
	# e.g: ero first.cpp second.cpp ...
	help_msg
	printf "\n"
	echo "Unknown argument(s): $argv[2..-1]"
	return 1
end

set -l all_input_files {$dir_with_name}.in*

# If a test id is specified, use only that input file if it exists
if set -q _flag_testId
	set tc_name {$dir_with_name}.in{$_flag_testId}
	
	if test -e $tc_name
		set all_input_files $tc_name
	else
		set all_input_files 
	end
end

set -l input_cnt (count $all_input_files)

if test $input_cnt -eq 0
	echo "No testcases available for this file: $filename"
	return 1
end

g++ -std=c++20 $argv[1] -o {$dir_with_name}.exe

# COMPILATION ERROR
if test $status -ne 0
	echo "Compilation error"
	return 1
end

set -l correct 0

function display
	set -f tc_result $argv[1]
	set -f tc_number $argv[2]
	set -f current_input_file $argv[3]
	set -f clr green

	switch $tc_result
		case "A C"
			set clr green
		case "W A"
			set clr red
		case "R T E"
			set clr yellow
	end
	
	printf "Test Case %d: " $tc_number
	
	# ------
	set_color -b $clr
	set_color black

	printf " %s " $tc_result

	set_color -b normal
	set_color normal

	printf "\n\n"
	# -----
	set_color -b white
	set_color black

	printf " Input  " 

	set_color -b normal
	set_color normal
	printf "\n\n"

	cat $current_input_file
	printf "\n"

	# -----
	set_color -b $clr
	set_color black

	printf " Output " 

	set_color -b normal
	set_color normal
	printf "\n\n"
	#-------
end

printf "\n"

for i_tc in (seq 1 $input_cnt)
	set current_input_file $all_input_files[$i_tc]
	# To get the number in the input file name e.g 2 -> file.in2
	set current_input_number_list (string split "." $current_input_file)
	set current_input_number $current_input_number_list[-1]
	set current_input_number (string sub -s 3 $current_input_number)
	# ----

	set current_output_file {$dir_with_name}.out{$current_input_number} 
	set current_answer_file {$dir_with_name}.ans{$current_input_number} 

	{$dir_with_name}.exe<$current_input_file>$current_output_file 
	set -l run_status $status

	# RUNTIME ERROR
	if test $run_status -ne 0
		set tc_result "R T E"
		display $tc_result $i_tc $current_input_file 
		sigmean $run_status
		printf '\n'
		continue
	end
	# ---- 

	# Check if a corresponding answer file is available
	if not test -e $current_answer_file
		set tc_result "R T E"
		display $tc_result $i_tc $current_input_file 
		printf "%s not found\n\n" $current_answer_file
		continue
	end
	# ----

	# Trim leading and trailing whitespaces
	set -l answer_lines (cat $current_answer_file)
	set -l output_lines (cat $current_output_file)
	set -l answer_len (count $answer_lines)
	set -l output_len (count $output_lines)

	set -l to_remove
	set -l answer_to_remove
	set -l found_begin 0
	set -l found_end 0

	for i_out_len in (seq 1 $output_len)
		if test -z $output_lines[$i_out_len] && test $found_begin -eq 0
			# current line is empty
			set -a to_remove $i_out_len
		else
			set found_begin 1
		end

		if test -z $output_lines[(math $i_out_len "*" -1)] && test $found_end -eq 0
			# current line is empty
			set -a to_remove (math $i_out_len "*" -1)
		else
			set found_end 1
		end

		if test $found_begin -eq 1 && test $found_end -eq 1
			break
		end
	end

	set found_begin 0
	set found_end 0

	for i_ans_len in (seq 1 $answer_len)
		if test -z $answer_lines[$i_ans_len] && test $found_begin -eq 0
			# current line is empty
			set -a answer_to_remove $i_ans_len
		else
			set found_begin 1
		end

		if test -z $answer_lines[(math $i_ans_len "*" -1)] && test $found_end -eq 0
			# current line is empty
			set -a answer_to_remove (math $i_ans_len "*" -1)
		else
			set found_end 1
		end

		if test $found_begin -eq 1 && test $found_end -eq 1
			break
		end
	end

	for idx in $to_remove
		set -e output_lines[$idx]
	end

	for idx in $answer_to_remove
		set -e answer_lines[$idx]
	end
	# ---- 

	# Re-assign the variables
	set answer_len (count $answer_lines)
	set output_len (count $output_lines)
	# ----

	set -l output_string (string join '' $output_lines)
	set -l answer_string (string join '' $answer_lines)
	set -l max_len (math max $answer_len, $output_len)

	# Putting $answer_string in "" is important so that it does not error out when it is empty
	if test "$output_string" = "$answer_string"
		set tc_result "A C"
		set correct (math $correct + 1)
	else
		set tc_result "W A"
	end

	display $tc_result $i_tc $current_input_file 

	for i_max_len in (seq 1 $max_len)
		if test $i_max_len -le $output_len && test $i_max_len -le $answer_len
			if test $output_lines[$i_max_len] = $answer_lines[$i_max_len]
				
				set_color green
				printf "%d) " $i_max_len
				set_color normal
				
				printf "%s\n" $output_lines[$i_max_len]
			else
				set_color red
				printf "%d) " $i_max_len
				set_color normal
				
				printf "%s" $output_lines[$i_max_len]
				printf " | "
				printf "%s\n" $answer_lines[$i_max_len]
			end
		else if test $i_max_len -le $output_len
			set_color red
			printf "%d) + " $i_max_len
			set_color normal
				
			printf "%s\n" $output_lines[$i_max_len]
		else
			set_color red
			printf "%d) - " $i_max_len
			set_color normal
				
			printf "%s\n" $answer_lines[$i_max_len]
		end
	end
	
	printf "\n"
end

# SUMMARY
printf "         %s\n" (string repeat -n (math 10 + (string length $correct) + (string length $input_cnt)) '-')
printf "Summary: "
printf "| %d / %d " $correct $input_cnt

set_color green
printf "%s" AC
set_color normal

printf " |\n"
printf "         %s\n" (string repeat -n (math 10 + (string length $correct) + (string length $input_cnt)) '-')
# ----
