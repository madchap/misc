# Bluetooth Linux tips
(feb 12 2017 - opensuse tumbleweed - Gnome)

> Either keyboard or trackpad works fine, but the 2 together is causing much problem.
> The Zik3 pairs OK, but sounds chops very badly at some point, where it becomes unusable...

## Pre-requisites
Add the following to the bottom of your /etc/pulse/system.pa and do a `pulseaudio -k` to restart the pulseaudio deamon (or reboot your box)

```
load-module module-bluez5-device
load-module module-bluez5-discover
```

## Apple bluetooth keyboard (not the newest one but the one which still has like regular batteries) bluetooth hints

Could have possibly be done via a UI but have not tried.

* Shutdown any mac that has that keyboard registered
* Enter `bluetoothctl`

```
agent KeyboardDisplay
default-agent
scan on
```

Press the side button of the keyboard until your keyboard enters pairing mode

A new device should pop-up

`[NEW] Device 28:37:37:36:75:0C 28-37-37-36-75-0C`

* Pair the keyboard - you will have to enter the pairing code
```
[bluetooth]# pair 28:37:37:36:75:0C
Attempting to pair with 28:37:37:36:75:0C
[CHG] Device 28:37:37:36:75:0C Connected: yes
[agent] PIN code: 995429
[CHG] Device 28:37:37:36:75:0C Modalias: usb:v05ACp0256d0050
[CHG] Device 28:37:37:36:75:0C UUIDs: 00001124-0000-1000-8000-00805f9b34fb
[CHG] Device 28:37:37:36:75:0C UUIDs: 00001200-0000-1000-8000-00805f9b34fb
[CHG] Device 28:37:37:36:75:0C ServicesResolved: yes
[CHG] Device 28:37:37:36:75:0C Paired: yes
Pairing successful
```

I then ungeekly went to the bluetooth menu of gnome, and could see the keyboard.
![alt text][keyboard-mini-bluetooth]
[keyboard-mini-bluetooth]: https://raw.githubusercontent.com/madchap/misc/master/images/mini_bluetooth_keyboard.png

The first try to bind it failed oddly, but the second time when straight in.

## Apple trackpad
Pretty much the same as for the keyboard

```
[Clavier mini]# agent on
Agent registered

[Clavier mini]# default-agent
Default agent request successful

[Clavier mini]# scan on
Discovery started

[CHG] Controller 00:0A:CD:2D:62:27 Discovering: yes
[CHG] Device F1:F5:A9:FE:B9:C4 RSSI: -76
[NEW] Device 60:C5:47:87:A5:E0 60-C5-47-87-A5-E0
[CHG] Device 60:C5:47:87:A5:E0 LegacyPairing: no
[CHG] Device 60:C5:47:87:A5:E0 Name: Trackpad mini
[CHG] Device 60:C5:47:87:A5:E0 Alias: Trackpad mini
[CHG] Device 60:C5:47:87:A5:E0 LegacyPairing: yes

[Clavier mini]# trust 60:C5:47:87:A5:E0
[CHG] Device 60:C5:47:87:A5:E0 Trusted: yes
Changing 60:C5:47:87:A5:E0 trust succeeded

[Clavier mini]# pair 60:C5:47:87:A5:E0
Attempting to pair with 60:C5:47:87:A5:E0
[CHG] Device 60:C5:47:87:A5:E0 Connected: yes
[CHG] Device 60:C5:47:87:A5:E0 Modalias: usb:v05ACp030Ed0160
[CHG] Device 60:C5:47:87:A5:E0 UUIDs: 00001124-0000-1000-8000-00805f9b34fb
[CHG] Device 60:C5:47:87:A5:E0 UUIDs: 00001200-0000-1000-8000-00805f9b34fb
[CHG] Device 60:C5:47:87:A5:E0 ServicesResolved: yes
[CHG] Device 60:C5:47:87:A5:E0 Paired: yes
Pairing successful

[CHG] Device 60:C5:47:87:A5:E0 ServicesResolved: no
[CHG] Device 60:C5:47:87:A5:E0 Connected: no
[CHG] Device 60:C5:47:87:A5:E0 RSSI: -77
[CHG] Device 60:C5:47:87:A5:E0 RSSI: -66
[CHG] Device 60:C5:47:87:A5:E0 RSSI: -76
[CHG] Device 60:C5:47:87:A5:E0 RSSI: -64
[CHG] Device 60:C5:47:87:A5:E0 Connected: yes
[CHG] Device 60:C5:47:87:A5:E0 ServicesResolved: yes
```
![alt text][trackpad-bluetooth]
[trackpad-bluetooth]: https://raw.githubusercontent.com/madchap/misc/master/images/mini_bluetooth_trackpad.png

## Parrot Zik 3 on linux

Trust, and pair, as for the above devices.

The headset will even autoconnect when powered on (provided no other paired devices are there before, but that's a known behavior).

The sound becomes so choppy though, it is not really usable. Some talk about radio interferences, I don't know. Only with Linux then. It happens when using the A2DP sink output, HSP output is not choppy, but forget about having a proper sound then.

![alt-text][zik3]
[zik3]: https://raw.githubusercontent.com/madchap/misc/master/images/zik3.png

Archlinux has some awesome doc: https://wiki.archlinux.org/index.php/Bluetooth_headset

Let me know if you can make it work perfectly. (Macs are good for that...)

UPDATE: Looks like adding 'threadirqs' to the kernel boot params makes a HUGE different in my openSUSE tumbleweed!
```
sudo sed -i 's!quiet showopts"!quiet showopts threadirqs"!' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
Reboot.

If gdm pulseaudio is taking over your own user's pulseaudio process, kill the gdm's one. This will free a2dp sink for your use.

Seems related to https://bugs.freedesktop.org/show_bug.cgi?id=58746 -- bluetooth buffering and pulseaudio shit (man... nearly a decade we hear pulseaudio is s---  hahaha... like evolution MTA ^^, but well. I guess it is still better than what it used to be. We just hoped it was _even_ better!)

# Other stuff to remember
## Apple slim aluminium keyboard ISO layout fix
https://help.ubuntu.com/community/AppleKeyboard

`echo 0 | sudo tee /sys/module/hid_apple/parameters/iso_layout`

## Non-breaking space (a.k.a non-ascii that make your code or shell command break)
https://help.ubuntu.com/community/AppleKeyboard

Add this to your .Xmodmap
```
keycode 65 =space space
```
