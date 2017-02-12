# Bluetooth Linux tips
(feb 12 2017 - opensuse tumbleweed - Gnome)

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

* Trust the keyboard
```
[bluetooth]# trust 28:37:37:36:75:0C                                                                           
[CHG] Device 28:37:37:36:75:0C Trusted: yes
Changing 28:37:37:36:75:0C trust succeeded
[CHG] Device 28:37:37:36:75:0C LegacyPairing: yes
```

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
[alt text][keyboard-mini-bluetooth]
[keyboard-mini-bluetooth]: https://github.com/madchap/misc/

The first try to bind it failed oddly, but the second time when straight in.

## Apple trackpad

## Parrot Zik 3 on linux
