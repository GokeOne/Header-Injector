# Description
This is a bash script that tests for potential header injection vulnerabilities by sending HTTP requests with various custom headers and values. It compares the content length of each response against a baseline request to detect discrepancies, which may indicate potential security issues.

# Features
- Header Injection: Test various HTTP headers with specific values to see if they cause a change in the response size.
- Custom Payloads: Load custom payloads from a file to test for specific header injections.
- Baseline Comparison: Establishes a baseline content length from a normal request and compares it to the results of the injections.
- Timeout Support: Allows the specification of a request timeout.

# Prerequisites
curl: The script uses `curl` to make HTTP requests.
Bash: The script is written for Bash environments.

# Usage
`./script.sh -u https://target.com/resource [-p payload_file] [-t timeout]`

**Options** 
-u URL: (Required) Target URL to test for header injection.

-p payload_file: (Optional) File containing custom values for header injection. Each value should be on a new line.
-t timeout: (Optional) Timeout for each HTTP request in seconds.
-h: Displays the help/usage information.

# Script Behavior
Baseline Request: The script first makes a "baseline" request to the target URL without any custom headers and records the content length of the response.
Header Injection: It then tests a list of common headers with various values (including custom values from a payload file, if provided).
Comparison: For each injection, the script compares the response content length with the baseline and logs the result in the report file.
Timeout: If a timeout is set, it will apply to all requests made by the script.

# Custom payload
If you wish to use your own values for header injections, create a file (e.g., payload.txt) and add one value per line. Pass this file with the -p option when running the script.

Example payload.txt:
``10.0.0.1
192.168.0.1
localhost
``

**Note**: This tool is designed for educational and testing purposes only. Ensure you have permission to test the target before running this script. Misuse of this tool may violate legal or ethical guidelines.
