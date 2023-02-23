# Fetch a secret from Azure Key Vault using Managed Identity in Free Pascal

Free Pascal (originally named FPK Pascal) is a 32-bit and 64-bit modern Pascal compiler. It is available for different processors (including the Intel 80386 and compatibles and Motorola 680x0) and operating systems (Linux, FreeBSD, NetBSD, DOS, Windows, OS/2, BeOS, SunOS (Solaris), QNX and Classic Amiga).

The language syntax is semantically compatible with Turbo Pascal 7.0 as well as most versions of Delphi (classes, rtti, exceptions, ansistrings). Furthermore Free Pascal supports function overloading, operator overloading and other such features.

## Usage
1. Enable Managed Identity on the VM and assign permissions for that VM in your Key Vault (Secret Get operation)

2. Get an Ubuntu image (18.04 or above) and `apt get install fpc lazarus`.

2. Compile and run:
    ```sh
    $ make
    $ ./secrets
    ```
