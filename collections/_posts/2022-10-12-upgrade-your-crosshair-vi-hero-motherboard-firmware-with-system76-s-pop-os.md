---
updatedAt: 2022-10-21T17:38:49.434Z
layout: post
title: Upgrade your Crosshair VI Hero Motherboard Firmware with System76's PopOS!
subheading: I was doing a bit of yak shaving this morning, and it looks like it might have paid off.
slug: upgrade-your-crosshair-vi-hero-motherboard-firmware-with-system76-s-pop-os
date: 2022-10-12
author: Charles
author_image: /uploads/c_avatar_30ba895a14.webp
banner_image: /uploads/galactic_andromeda_workstation_393e5d94d4.webp
banner_image_description: a fresh computer desk with monitors from the Andromeda Galaxy.
category: How-to
tags: Repairs, Debugging, Troubleshooting, 
---
My grandpa always said: "if it ain't broke, it needs no fixin!"

   I started having trouble with random occurrences of my computer crashing on both Linux and Window's operating systems. This article details some of the steps I mazed through and will expedite spacetime support for future dilemmas.

After tinkering and pondering on the possible reasons, I deduced it down to either the GPU, Motherboard or potentially the PSU voltage irregularities. The GPU & RAM worked like a champ while stress testing them. I was unable to reproduce the random occurrence of this hard crash, and both Ubuntu 22.04 and Windows 10 never provided any error logs I could trace through. After each crash, I would restart and save the logs to maybe find a pattern between all the crashes, but sorting through all this didn't even provide a solution!

The PopOS! logs:
```
sudo journalctl --since today --output=short > ~/Documents/System\ Logs/today-1.log
journalctl -p 3 -xb
```

The Windows 10 logs:
```
Windows key + R 
input: eventvwr and tap the enter key
navigate through the GUI...
```

To deduce it further, the physical symptoms were: 
* The computer visuals on screen would freeze for a few seconds and then the monitors would all turn off, but the computer fans and motherboard lights stayed online.
* No error logs to trace on both Windows or Linux Ubuntu
* Random occurrences with intense and normal visuals 
* It happened with more than one browser like Firefox and Google Chrome

Normally, I would do a hard reset after it would crash and mistakenly overlooked the error code that was displayed after the crash; anyhow, the QCODE I received was: **08**. Upon further investigation and mazing around with the software bios utilities, I discovered I had a little button that would do all this in a *Flash*.

## Requirements & Safety

* Linux OS; Windows 11 is similar, but the commands are different.
* Basic electronic principles
* Always make backups
* Create a bootable drive in case bootloader messes up after update (see here)
* Backup procedures in-case BIOS update fails
* A official manual for your motherboard 

*WARNING:* You are soley responsible for your own hardware; this article is the process of how I have successfully troubleshooted my own hardware. 

1. Get BIOS & Motherboard Information
```sudo dmidecode --type 0```

```
# dmidecode 3.3
Getting SMBIOS data from sysfs.
SMBIOS 3.2.0 present.

Handle 0x0000, DMI type 0, 26 bytes
BIOS Information
	Vendor: SharpeTronics Inc.
	Version: 1501
	Release Date: 07/3/2017
	Address: 0xF0000
	Runtime Size: 64 kB
	ROM Size: 16 MB
	Characteristics:
		PCI is supported
		APM is supported
		BIOS is upgradeable
		BIOS shadowing is allowed
		Boot from CD is supported
		Selectable boot is supported
		BIOS ROM is socketed
		EDD is supported
		5.25"/1.2 MB floppy services are supported (int 13h)
		3.5"/720 kB floppy services are supported (int 13h)
		3.5"/2.88 MB floppy services are supported (int 13h)
		Print screen service is supported (int 5h)
		8042 keyboard services are supported (int 9h)
		Serial services are supported (int 14h)
		Printer services are supported (int 17h)
		ACPI is supported
		USB legacy is supported
		BIOS boot specification is supported
		Targeted content distribution is supported
		UEFI is supported
	BIOS Revision: 1.17
```

The above output allows us to verify the BIOS

```sudo dmidecode --type 2```

```
Handle 0x0002, DMI type 2, 15 bytes
Base Board Information
	Manufacturer: ASUSTeK COMPUTER INC.
	Product Name: CROSSHAIR VI HERO
	Version: Rev 1.xx
	Serial Number: 0x0x0x0x0x0x0x
	Asset Tag: Default string
	Location In Chassis: Default string
	Chassis Handle: 0x0003
	Type: Motherboard
	Contained Object Handles: 0
```

2. Download the Firmware from Manufacturer's Website

Navigate to the firmware page and download the most recent firmware update for your CROSSHAIR VI HERO: [link](#sources)

3. After you download the new firmware, we open & rename the file to **C6H.CAP**, then *duplicate* or move it to the *root* of the *USB device*. 

The instructions are provided by the manufacturer; you may discover this information online or the actual manual shipped with your motherboard. For this use case scenario, the ASUS Crosshair VI Hero motherboard has a BIOS button that sweeps or extracts the file and updates your firmware in about 3-5min with a ~17mb file. 

4. Upgrade your Motherboard Firmware

If you're also upgrading the: ROG CROSSHAIR VI HERO Motherboard to *version 8601*, the page of reference is located in "**Chapter 2.2 BIOS update utility : USB BIOS Flashback**".

To use USB BIOS Flashback:
```
1.Download the latest BIOS file from the ASUS website.
2.Extract and rename the BIOS image file to C6H.CAP.
3.Copy C6H.CAP to the root directory of your USB storage device.
4.Turn off the system and connect the USB storage device to the USB BIOS Flashback port.
5.Press the USB BIOS Flashback button.
```

The method above allows an owner to update their motherboard without mazing around in the BIOS software. You simply plug-in the USB device into the **correct port** and **press** the button. 

The button will **blink blue slowly then speed up as time progress's**; I spent about 3-5 minutes flashing the BIOS this way; before, I have had horror stories flashing the BIOS with the BIOS. For example, I was unable to successfully make use of the other two tools the manufacturer provided because the software would bug out. The simplest and most effective method is using a USB BIOS Flashback button that is physically located on your motherboard.

## Other Misc. Testing

Some other things I spent doing before I reached a solution were the following:

* Upgraded all disk drivers
* Lots of research
* Re-seated all motherboard connections
* Cleaned and dusted all dust on the grill and fans.
* Cleaned and Reapplied thermal paste to CPU
* Re-seated and clean the GPU
* Reinstalled Windows and Linux OS
* Contacted a support channel with another company
* The bug could be related to AMD's fTPM feature. [link](#sources)
* ...many more...

 In conclusion, the entire machine has been revitalized, including both software and hardware. The bug has been resolved and I can get back to doing other cool stuff and things. In the future, I will include how to repair your bootloader on Ubuntu and Windows after upgrading your BIOS; in the meantime, if you need this ASAP, System76 has a well written article on the topic at hand at: [link](#sources).

### Sources

[Repair Your Linux Bootloaders - System76](https://support.system76.com/articles/bootloader/){:target="_blank"}

[AMD fTPM Stuttering Issues - Toms Hardware](https://www.tomshardware.com/news/amd-issues-fix-and-workaround-for-ftpm-stuttering-issues
){:target="_blank"}

[ASUS Crosshair VI Hero Drivers & Manuals](https://rog.asus.com/us/motherboards/rog-crosshair/rog-crosshair-vi-hero-model/helpdesk_bios/){:target="_blank"}
