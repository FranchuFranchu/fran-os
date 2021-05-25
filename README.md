# fran-os

Open-source public domain (zero-clause BSD) operative system written in x86 assembly (Intel syntax)

Feel free to use it for guides, tutorials, or copy-paste from here into your own OS.

Compile using 

    make qemu

It will ask for superuser create the loopback device

### Potentially confusing code

I've decided to do this for future-proofing

	%define da dd
	%define resa resd
	
These should be used for any pointers to memory. Some of the old code still uses dd or resd though.

If we ever switch to 64-bit, then I'll change it to dq and resq, so that they have the appropiate size.