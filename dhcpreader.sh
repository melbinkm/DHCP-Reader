#!/bin/bash

# Set the DHCP lease file path(s)
DHCP_LEASES_FILES=("/var/lib/dhcp/dhcpd.leases")
DHCP_LEASES_FILES+=("/var/lib/dhcpd/dhcpd.leases") # Add support for multiple DHCP servers

# Check that the lease file(s) exist and are readable
for file in "${DHCP_LEASES_FILES[@]}"; do
  if [ ! -f "$file" ] || [ ! -r "$file" ]; then
    echo "Error: $file is missing or unreadable."
    exit 1
  fi
done

# Read the DHCP lease files and extract the lease information
while read -r line; do
  # Check if the line contains a lease start time
  if [[ $line =~ ^lease\ ([0-9\.]+)\ {$ ]]; then
    # Extract the IP address
    IP=${BASH_REMATCH[1]}
  fi

  # Check if the line contains a hardware ethernet address
  if [[ $line =~ ^\ \ \ \ hardware\ ethernet\ ([0-9A-Fa-f\:]+)\;$ ]]; then
    # Extract the MAC address
    MAC=${BASH_REMATCH[1]}
    # Lookup the vendor information for the MAC address
    VENDOR=$(maclookup $MAC | awk -F"\t" '{print $3}')
    # Get the device name (if available) from DNS
    NAME=$(dig -x "$IP" +short | sed 's/\.$//')
    # Check if the device matches the filter criteria
    if [[ -z "$FILTER" || "$IP" =~ $FILTER || "$MAC" =~ $FILTER || "$NAME" =~ $FILTER || "$VENDOR" =~ $FILTER ]]; then
      # Add the device information to the device list
      DEVICE_LIST+=("$IP|$MAC|$NAME|$VENDOR")
    fi
  fi
done < <(cat "${DHCP_LEASES_FILES[@]}" | grep -E "lease|hardware ethernet")

# Sort the device list based on the specified sort order
case $SORT in
  "ip")   SORT_COLUMN=1 ;;
  "mac")  SORT_COLUMN=2 ;;
  "name") SORT_COLUMN=3 ;;
  "vendor") SORT_COLUMN=4 ;;
  *)      SORT_COLUMN=1 ;;
esac
IFS=$'\n' DEVICE_LIST=($(sort -t '|' -k $SORT_COLUMN <<<"${DEVICE_LIST[*]}"))
unset IFS

# Print the device list in a table format
printf "+-----------------+-------------------+--------------------------------+--------------------------------+\n"
printf "| %-15s | %-17s | %-30s | %-30s |\n" "IP Address" "MAC Address" "Device Name" "Vendor Information"
printf "+-----------------+-------------------+--------------------------------+--------------------------------+\n"
for device in "${DEVICE_LIST[@]}"; do
  IFS='|' read -r IP MAC NAME VENDOR <<< "$device"
  printf "| %-15s | %-17s | %-30s | %-30s |\n" "$IP" "$MAC" "$NAME" "$VENDOR"
done
printf "+-----------------+-------------------+--------------------------------+--------------------------------+\n"
