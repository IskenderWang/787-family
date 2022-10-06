# 787-family

Boeing 787 family for FlightGear: the result of a successful attempt to merge [Jonathan Redpath's abandoned -9](https://github.com/legoboyvdlp/787-9) with the [FGAddon 787-8](http://sourceforge.net/p/flightgear/fgaddon/HEAD/tree/trunk/Aircraft/787-8/).

This is the official home of the unified 787 family, based on the two models listed above.

After gitorious closed down and former maintainer Omega95 retired, islandmonkey created a GitHub repo, which was subsequently merged into FGAddon. Now, IskenderWang and Marsdolphin, among others, are collaborating on a project that aims to improve the quality of the 787 and several of its variants.

NOTE: The autopilot now fully operates on the latest version of [Octal450's excellent ITAF system](https://github.com/Octal450/IT-AUTOFLIGHT) – see [here](http://wiki.flightgear.org/IT-AUTOFLIGHT) for more information.

## This package contains the following models:

- 787-8 (GEnx & RR Trent)
- 787-9 (GEnx & RR Trent)
- 787-10 (GEnx & RR Trent)

## Install

As easy as downloading or cloning this repo and placing it in your folder for custom aircraft in FG (you should make sure this folder you place it in is named Aircraft – the path in which you have this "Aircraft" folder is entirely up to you though). For more information, you can have a look at the [Wiki article](https://wiki.flightgear.org/Boeing_787-8_Dreamliner). We intend to update it in short order with new information about all the work we've done here :)

### Troubleshooting

Over the course of our time developing this project, some recurring issues have been brought to our attention.
Luckily, we're now at a stage where we know exactly how each can be solved. So, here are a few that seem to be the most common and their solutions:

- **I can't get started/I only see a placeholder model**: To have everything working, make sure the folder is named 787-family (no -master after if downloading zip)!

- **I pulled the latest changes and now I ain't got any wings**: This is most likely to happen if you never ran `git pull` for a while. What could occur in such a case is that when you do so from an old state, Git may have some trouble merging/resolving the history and how it's developed since then (we're told some force pushes could be to blame) which could then cause a number of problems like absent wings, due to a discrepancy with the model files (.ac) – this makes sense, considering that the model files have consistently had extensive changes made to them in our efforts to improve them. If this has happened to you, the best solution we can offer is to run the following commands:

```sh
git fetch origin # just in case
git reset --hard origin/master # best bet, later if you want you can switch branches
```

- If, for whatever reason in the world, that DOESN'T work, then this should for sure: simply delete that directory entirely and then `git clone` this repo once again to receive a fresh and fully working revision.
  
- **I'm not getting enough power during takeoff**: First and foremost, check to be certain that your engine generators are ON by the time you're lined up (you probably already did this as soon as your engines were fully running). Now, for the key thing: *make sure your ***APU gen*** switch is turned **OFF*** before you begin your takeoff roll. For some reason we haven't determined yet, the electrical system doesn't default to the engine generators if the APU gen is on as well, which I suspect leads to insufficient engine power – so, to prevent any power draw that could delay vR, you'll have to flip it to the OFF position. As for the APU itself, there are several courses of action one can take. Some prefer to turn it off as soon as their engines come alive, while others may wait until a short while after takeoff as just an extra precaution should either of the engines fail in the critical time directly after the rotation for takeoff.

## Livery Contribution

If you made a livery, and want it to be added make sure to create a fork, add it there and create a pull request, make sure the livery name is with the current standard of
```sh
<name type="string">ICAO Airline full name (Registration)</name>
```
Example
```sh
<name type="string">DLH Lufthansa (D-ABPD)</name>
```
