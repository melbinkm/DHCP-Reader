# DHCP Reader

`dhcpreader` is a Bash script that reads a DHCP lease file and displays information about connected devices. It extracts the IP address, MAC address, device name (if available), and vendor information for each device that has been assigned an IP address by the DHCP server. The script outputs the device information in a table format that is easy to read.

## Requirements

-   Bash shell
-   `maclookup` tool (for vendor information lookup)
-   `dig` command (for device name lookup)

## Usage

To run the script, open a terminal window and navigate to the directory where the script is saved. Then, run the following command:

`./dhcpreader.sh` 

By default, the script reads the DHCP lease file located at `/var/lib/dhcp/dhcpd.leases`. If you are using a different DHCP server or the lease file is located in a different directory, you can modify the `DHCP_LEASES_FILE` variable in the script to specify the correct path.

## Filtering and Sorting

You can use the `FILTER` and `SORT` variables in the script to filter and sort the devices based on specific criteria.

-   To filter devices, set the `FILTER` variable to a regular expression that matches the desired criteria. For example, to filter devices based on IP address range, you can set `FILTER` to a regular expression like `"192\.168\.[0-9]+\.[0-9]+"`.
    
-   To sort devices, set the `SORT` variable to the desired sort order (`ip`, `mac`, `name`, or `vendor`). By default, the script sorts the devices based on IP address.

Here's an example of how you can run the script with filtering and sorting options:

```./dhcpreader.sh FILTER="192\.168\.[0-9]+\.[0-9]+" SORT="vendor" ``` 

## Output

When you run the script, it will display a table of information about the devices that are currently connected to the network. 

The table includes columns for IP address, MAC address, device name (if available), and vendor information. The information is sorted based on the `SORT` variable (default is by IP address) and filtered based on the `FILTER` variable (default is no filter).
