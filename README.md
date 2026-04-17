# Advanced NETCONF Explorer
Advanced NETCONF explorer and NETCONF client library for Java

This is a graphical explorer for YANG models supported by a NETCONF device or service orchestrator. Features include:
* Retrieving all YANG models supported by a device or orchestrator using the NETCONF monitoring standard.
* Parsing the YANG models (using ODL yangtools) and outputting a tree with all the nodes, which the user can expand / collapse.
* Filtering the model tree by module name and searching the names and descriptions of the YANG nodes in it (e.g. “neighbor count” or “bgp” “neighbor count”).
* Downloading a ZIP-Archive of all YANG-models supported by the device or orchestrator.
* Showing details and generating metadata for a YANG node, e.g. the description, the (sensor-)path, a subtree-filter (for NETCONF development) etc.
* GNMI and IOS XR Telemetry support tools to edit sensor groups and show live data using GRPC.
* Browsing and searching live (operational) data for selected YANG models.

## Recent Updates (2026)

### Why This Project Was Updated

The original ANX codebase was maintained but relied on outdated dependencies that were no longer actively maintained:

**Original Issues:**
- **Debian Buster (EOL)**: The original `debian:buster-slim` base image reached end-of-life, making it difficult to install modern packages or apply security updates
- **Manual apt-get installs**: OpenJDK 11 and Jetty 9 were installed via apt, which often had timing issues and version incompatibilities
- **Poor error diagnostics**: YANG model parsing failures showed only generic error messages, making debugging difficult
- **Missing cache validation**: The yangcache directory creation wasn't guaranteed, causing silent failures during schema downloads

**Solutions Applied:**
1. **Modern multi-stage Docker build** using official, actively-maintained images
2. **Detailed parse error reporting** to distinguish between download failures, schema resolution issues, and import dependencies
3. **Robust cache directory creation** with proper permissions
4. **Complete documentation** for troubleshooting common issues

## Setup
### Using Docker

You can easily build and run using docker:
* `docker build -t netconf-explorer .`
* `docker run --name netconf-exlorer -d -p 9269:8080 netconf-explorer`

If you have docker-compose installed this can be shortened to:
* `docker-compose up -d`

**Docker Image Details (as of 2026):** The Dockerfile has been updated to use modern, actively maintained base images:
* Builder stage: `maven:3.9.9-eclipse-temurin-11` (Maven 3.9.9 with Eclipse Temurin JDK 11)
* Runtime stage: `jetty:9.4.57-jre11` (Jetty 9.4.57 with OpenJDK 11)
* Multi-stage build reduces final image footprint
* YANG model cache directory is automatically created at `/var/lib/yangcache`

Note: You need at least 2-3 GB of RAM on your Docker (Virtual) Machine to run this application. In case you are running it on your
laptop, please increase the RAM assigned to Docker to 3 GB. See https://docs.docker.com/docker-for-windows/#advanced or
https://docs.docker.com/docker-for-mac/#advanced

### Using JDK and Maven
If you have a working Java development environment with maven on your machine, you can also launch the explorer with an embedded webserver using:
* `mvn -e -f anc/pom.xml install`
* `mvn -e -f grpc/pom.xml install`
* `mvn -e -f explorer/pom.xml jetty:run`

You can also create a WAR file for deployment in an application server using
* `mvn package`

## Using the Explorer

Access port 9269 (or 8080 for the embedded webserver) of the host using a browser. You can then use the explorer to connect to any NETCONF / Yang
enabled device or orchestrator supporting NETCONF Monitoring [RFC 6022](https://tools.ietf.org/html/rfc6022).

1. Enter a hostname or IP-address in the "NETCONF Host"-field (optionally followed by a colon and the NETCONF over SSH port) and input the username and password into the corresponding fields and click "Login". 

2. The explorer will now download and parse all available YANG models. This process may take a minute or two.

3. The following start screen is divided in two parts. On the left-hand side you have a menu listing all YANG models including a simple name-based search and the option to show an individual YANG model in source or download all YANG models as a ZIP-file. On the right-hand side you have the data model tree which allows you to browse and search within the data model (the search will match against the YANG field names and descriptions). If you click on an element details will be shown on the left-hand side.

4. By selecting one or more nodes in the model tree so that they are highlighted in blue, you can use the "Show Data" function to retrieve and visualize the corresponding operational or configurational data from the device. The model tree will then be replaced by the data tree for the selected values and the search bar will let you search by both model names and also values. Again by clicking a node, details will be shown on the left-hand side.

5. For IOS-XR telemetry you will be able to view and edit sensors groups by using the Telemetry Tools on the left-hand side. Select or type the name of a sensor group and use Edit to make changes to it. If you have previously selected a node in the model browser, its sensor path will be prepopulated in the sensor group editor for convenience. If your device runs a 64-bit version of IOS XR, you can also view a JSON-encoding of the live feed of the Telemetry data exactly as it is sent to your telemetry collector.



## Troubleshooting

### YANG Model Parsing Failures
If the explorer fails to parse downloaded YANG models, check the application logs for detailed error messages:
```bash
docker logs -f anx-anx-1
docker logs anx-anx-1 2>&1 | grep -E "Failed to parse|SchemaResolutionException|Exception"
```

The parser now provides detailed diagnostic information including:
* Specific schema resolution failures
* Missing model dependencies (imports)
* Cache directory creation issues

### WSL2 Network Access to VMware Networks
To allow WSL2 to reach VMware host-only networks (e.g., 192.168.74.0/24, 192.168.75.0/24):

Edit `%UserProfile%\.wslconfig` and ensure:
```ini
[wsl2]
networkingMode=nat
dnsTunneling=true
autoProxy=true
```

Then restart WSL:
```powershell
wsl --shutdown
```

This allows ANX running in WSL to reach NETCONF devices on VMware networks.

## ANC - Java NETCONF client library
ANC is the basis of the explorer and offers abstraction for most of the features of NETCONF.
It is packaged as a maven artifact so it can be installed using `mvn install` in the `anc` directory. 

