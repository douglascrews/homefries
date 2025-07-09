echo "Colors setup..."

export colorBlack='\e[0;30m'
export colorDarkGray='\e[1;30m'
export colorBlue='\e[0;34m'
export colorLightBlue='\e[1;34m'
export colorGreen='\e[0;32m'
export colorLightGreen='\e[1;32m'
export colorCyan='\e[0;36m'
export colorLightCyan='\e[1;36m'
export colorRed='\e[0;31m'
export colorLightRed='\e[1;31m'
export colorPurple='\e[0;35m'
export colorLightPurple='\e[1;35m'
export colorBrownOrange='\e[0;33m'
export colorYellow='\e[1;33m'
export colorLightGray='\e[0;37m'
export colorWhite='\e[1;37m'
export colorReset='\e[0m'
# echo -e ${colorBlack} Black ${colorDarkGray} Dark Gray ${colorBlue} Blue ${colorLightBlue} Light Blue ${colorGreen} Green ${colorLightGreen} Light Green ${colorCyan} Cyan ${colorLightCyan} Light Cyan ${colorRed} Red ${colorLightRed} Light Red ${colorPurple} Purple ${colorLightPurple} Light Purple ${colorBrownOrange} Brown/Orange ${colorYellow} Yellow ${colorLightGray} Light Gray ${colorWhite} White ${colorReset}

# Color formatting of function help messages:
#   local default_gender="female"
#   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
#      help_headline "${FUNCNAME}" "name" "[age]" "[gender]"
#      help_param "name" "This is a required parameter"
#      help_param "[age]" "This is an optional parameter with no default"
#      help_param "[gender]" "This is an optional parameter with a default value" "${default_gender}"
#      help_note "*Note: " "This function has a side effect. " "!It might destroy the world."
#      return 0;
#   }

export color_param_required=${colorLightCyan} # parameter, required; param_name
export color_param_optional=${colorCyan} # parameter, optional; [param_name]
export color_param_default=${colorLightPurple} # parameter, default value; positional
export color_help_message=${colorDarkGray} # Help output, message text; "message text"
export color_help_warning=${colorRed} # Help output, warning text; "!warning text"
export color_help_emphasize=${colorLightRed} # Help output, emphasized "*emphasized text"
export color_help_function_name=${colorLightBlue} # Function name output

# Help output, function name and parameter list
# USAGE: help_headline ${FUNCNAME} required_param1 required_param2 ... [optional_param1] [optional_param2] ...
function help_headline() {
   local _message="${color_help_function_name}${1}${colorReset}"
   shift
   for param in "${@}"; do
      # if parameter is enclosed in square brackets, it is optional
      if [[ ${param} =~ \[.*\] ]]; then # optional parameter
         _message="${_message} ${color_param_optional}${param}${colorReset}"
      else # required parameter
         _message="${_message} ${color_param_required}${param}${colorReset}"
      fi
   done
   echo -e "${_message}${colorReset}"
}
export -f help_headline

# Help output, parameter explanation
# USAGE: help_param param_name "This is the purpose of the param" default_value
function help_param() {
   local _message="\t"
   # if parameter is enclosed in square brackets, it is optional
   if [[ ${1} =~ \[.*\] ]]; then # optional parameter
      _message="${_message}${color_param_optional}${1}${colorReset}"
   else # required parameter
      _message="${_message}${color_param_required}${1}${colorReset}"
   fi
   _message="${_message}\t${color_help_message}${2}${colorReset}"
   if [[ -n "${3}" ]]; then # default value provided
      _message="${_message}${color_help_message}; default=${color_param_default}${3}${colorReset}"
   fi
   echo -e ${_message}${colorReset}
}
export -f help_param

# Help output, general notes
# USAGE: help_note '*Yo, check it out. ' 'This function is awesome, ' '!but it will destroy the world!'
function help_note() {
   local _message=""
   for param in "${@}"; do
      if [[ ${param} =~ \!.* ]]; then # warning
         _message="${_message}${color_help_warning}${param#*\!}${colorReset}"
      elif [[ ${param} =~ \*.* ]]; then # emphasize
         _message="${_message}${color_help_emphasize}${param#*\*}${colorReset}"
      else # normal message
         _message="${_message}${color_help_message}${param}${colorReset}"
      fi
   done
   echo -e ${_message}${colorReset}
}
export -f help_note
