# DNS Spoofing with WiFi Pineapple Mark VII

> __Author__::      TW-D
>
> __Version__::     1.0.0
>
> __Copyright__::   Copyright (c) 2022 TW-D

## Description

```

				    0
				    |
				{}====={}
				    |
				    |
				|   |   |
				|___|___|

------------------------------------------------------------------------------
* Author: TW-D
* Version: 1.0.0
* Documentation: https://github.com/TW-D
------------------------------------------------------------------------------

```

BASH script automating the registration of a new DNS entry in the "/etc/hosts" file 
of the "WiFi Pineapple Mark VII" and starting a local web server to deliver a phishing page.

__Note :__ *"Issues" and "Pull Requests" are welcome.*

## Requirements for the controller

```bash
sudo apt-get install jq php7.4-cli sshpass
```

## Usage

Modify the "./configuration.json" file for SSH control :

```json
{
    "PINEAPPLE_PASSWORD": "<ROOT-ACCOUNT-PASSWORD>",
    "PINEAPPLE_PORT": "22",
    "PINEAPPLE_IP": "172.16.42.1"
}
```

In the "./templates/" folder, create for example an HTML file with the name "www.example.com" 
containing the code of the "phishing" page.

In this case the second argument of the "./main.sh" file will also be "www.example.com".

```bash
sudo $BASH ./main.sh <LOCAL_IP> www.example.com 80
```

__Note :__ For each new DNS entry, an HTML file must be created in the "./templates/" folder. The link between the domain name and the page will be done automatically using the "./templates/index.php" file.
