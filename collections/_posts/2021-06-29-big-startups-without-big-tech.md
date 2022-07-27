---
layout: post
date: 2021-06-29
author: Charles
banner_image: /uploads/decentralized_385bd5a376.webp
banner_image_alt: An image of interconnecting objects
title: Big Startups Without Big Tech
sub_heading: Liquid Democracy Empowering Network Users
tags: Blockchain, Linux, 
category: How-to
---
Welcome to the Blockchain Internet called DFINITY. In my spare time, I have been tinkering and learning **Motoko**. It is a language built for the Internet Computer (IC) that can be used to interface applications, websites and other various software.

Motoko is a programming typed language that compiles into WebAssembly (WA) and is created by **Andreas Rossberg** & the **Dfinity Foundation**

> "To offer a seamless developer experience, we wanted to create a specialized programming language, called Motoko, that is designed to directly support the programming model of the Internet Computer, making it easier to efficiently build applications and take advantage of some of the more unusual features of this platform." -Andreas Rossberg


To begin development of the open decentralized Internet called Dfinity, I needed to install the Software Developer Kit (SDK).
I ran into a few challenges initially with using the **"dfx"** command after installing. I needed to setup my PATH and let **.bashrc** know where the program dfx is installed.
Knowing how to do this is important and enables more flow with development. Normally, these things are done by default when installing the program, but in unique scenarios, the installed location of that application may not be added to your .bashrc or profile.


### Let's begin,

0. Open up Linux terminal
1. `nano ~/.bashrc`
2. Scroll down to end of page and type the following code to add "dfx" command to your profile or .bashrc.
3. Rerun the updated .bashrc or .profile script via . ~/.bashrc, then test *"dfx --version"* again.
```
# DFINITY MOTOKO
export PATH=$HOME/bin:$PATH.
```
![Bashrc Edit for Linux](/uploads/2021/motoko_bashrc-edit.webp "Motoko Bashrc Edit")

What we have enabled here is the command **"dfx --version"** to work without having to type the entire path to execute the dfx program.
As an example, without setting up our PATH, we would type the full path of where the program is located in the terminal; this would be **"/home/username/bin/dfx --version"** to run the program each time we need it.

*If for some reason your dfx installed in a different location, all you need to do is run "which dfx" and it will provide the installed location of that program.*

I hope this quick tutorial aided in your Linux administration talents. I will begin sharing short tutorials like this. It will enable my own glossary of experience and also aid in other curious programmers and Linux users seeking answers. 🖖

#### Sources:
* Internet Computer Genesis Launch Event - <https://youtu.be/xiupEw4MfxY> - Premiered May 7, 2021
* The Dfinity Foundation - <https://dfinity.org/>
* Adding a Path to the Linux PATH variable - <https://www.baeldung.com/linux/path-variable> - May 13th, 2021
