+++
title = "My NixOS Configuration"
description = "Prelude"
date = 2026-01-01

[taxonomies]
series = ["NixOS Desktop"]
tags = ["Linux", "NixOS"]

[extra]
ToC = true
edit = true
comments = true
+++

# Under Construction!

This Page is still under development and may remain unfinished or subjected to major changes over time

# I don't know Linux

Go away already.  
If you’re looking for a beginner’s guide, this is not it. This is a postmortem of a bad idea that worked.

I sadly do not possess much patience, and quite frankly, most of the rest of this page/series will go over your head.  
However, if your tastes are sufficiently messed up - or if you enjoy watching someone over-engineer their computer to the point of absurdity - this might hopefully be a fun read.

My entire life has been a contradiction of sorts, notwithstanding the OS I currently use. I chose arguably the most difficult distro to learn to use specifically so I would never have to learn how to fix it again.

# What is this "NixOS" thing?

If you've ever used Linux before (like Ubuntu or Arch), you know the drill: you install the OS, you run a bunch of terminal commands to install software, you edit a text file here and there, and eventually, you have a system that feels like home.

But you also know the **fear**.

The fear that if you delete the wrong file, mess with the wrong package, or even upgrade to a new release, your computer might implode, and you'll have no idea how to get back to the way things were.

> That's \*\*\*\*\*\*\* it I'm switching back to Windows forever
>
> --> **Me**  
> (right after the 69420th distro-hop that caused my system to crash and burn)

**NixOS is different.**

Basically, you define a **blueprint** - a single configuration file that describes exactly how you want your computer to function. You want Firefox? You write `firefox` in the file. You wanna set your wallpaper? Just chuck it into the file.

After you're done, [Nix](https://github.com/NixOS/nix) looks at it, nods, and builds your entire operating system from scratch to match exactly what you wrote. If you mess up, you just undo the text in the file, and your computer goes back to being perfect.

---

_Now that the theatrics are out of the way, let's proceed to see more of it_

# The Descent into Madness

It started innocently enough. I just wanted a system that was **reproducible**.

I began with **Nix Flakes**, the "Gateway Drug" [^1] of the ecosystem. Instead of vaguely gesturing at a repository and hoping for the best, `flake.nix` locks every input dependency of my system to a specific commit hash. It is the ultimate insurance policy: if I compile this system today, or in about 10 years in the midst of an imminent meteor strike that may or may not wipe out all life, I will get the exact same binary output.

But having a reproducible system wasn't enough. It had to be **obedient**.

I pulled in [**Home Manager**](https://github.com/nix-community/home-manager) because configuring the OS wasn't enough; I needed to micromanage my user config files too. Then came [**Stylix**](https://github.com/nix-community/stylix). I declare a single image and a color scheme, and Stylix brutally enforces this theme across everything. It forces CSS into [Waybar](https://github.com/Alexays/Waybar), recompiles all my app themes, and even bullies my terminal into submission. But why stop there? I grabbed [**Spicetify**](https://github.com/Gerg-L/spicetify-nix) to force Spotify to match my aesthetic, and [**Nixcord**](https://github.com/FlameFlag/nixcord) for Discord cuz the default grey was offending my eyes.

**"Okay, it's pretty," you say. "But is it useful?"**

You have no idea.

I don't "install" development tools. I have a [directory](https://github.com/maydayv7/dotfiles/tree/main/shells) that defines isolated environments for C++, Python, JavaScript and so on. When I `cd` into a project, [Direnv](https://direnv.net/) and [**Lorri**](https://github.com/nix-community/lorri) kick in, and the compiler, linter, LSP and whatnot just _appear_ in my shell. When I leave, they vanish.

Every little thing is specified in code. Like when I open [VS Code](https://code.visualstudio.com/), my settings and extensions are already present, and automatically updated. Heck even my **_Printer_** configuration is defined in a Nix file. Yes, really.

**Oh, you thought that would be enough to satiate me?**

Please.

I needed to know that my system was _spiritually_ pure. So I formatted my drive with [ZFS](https://github.com/openzfs/zfs) (it's own merits aside) and implemented [**Impermanence**](https://github.com/nix-community/impermanence).
Every time I reboot, my root filesystem is nuked. Wiped. Gone. My OS is resurrected from a blank slate every boot, preserving only what I explicitly whitelist on a separate dataset.
To manage secrets without them dying in the purge, I use [**sops-nix**](https://github.com/Mic92/sops-nix) to encrypt passwords and API keys using GPG, directly into my publicly hosted `git` repo, without leaking any sensitive data.

**At this point most people would stop**

Well I didn't.

I still wanted to play games and run Android apps. A normal person would dual-boot or use an emulator. I chose violence.

I run [Waydroid](https://github.com/waydroid/waydroid) to virtualize Android directly on the Linux kernel. Then, for the pièce de résistance, I set up [VFIO](https://docs.kernel.org/driver-api/vfio.html) GPU Passthrough [^2]. I pass that GPU directly into a Windows Virtual Machine and use [Looking Glass](https://looking-glass.io/) to stream the video output back to my PC screen with negligible latency.

I've also declaratively configured [**Minecraft Servers**](https://github.com/Infinidoge/nix-minecraft) (that 2 week period lasted for months actually, don't judge) and [Wine](https://www.winehq.org/) applications (huge shoutout to [Erosanix](https://github.com/emmanuelrosa/erosanix)).

**The result of all this?**

If I buy a new computer today, I don't spend a week installing drivers and recovering passwords.

I clone my repository. I run one single command.

And I go get a coffee. Soon as I return [^3], I spin up a AAA Windows game, inside a VM, displayed on a tiling Linux WM (heck even choose between [Hyprland](https://hypr.land/) and [Niri](https://github.com/YaLTeR/niri)), on a system that deletes and rebuilds itself on every boot.

God, I love NixOS.

# A Fair Warning

Before you rush off to install this magical operating system, we need to have a serious chat.

**NixOS is hard.**

I don't mean "Linux is hard" kind of hard. I mean "I have to relearn how computers work" kind of hard.

- **It is not standard Linux**: Most tutorials you find on the internet simply will not work here. You can't just `apt install` your problems away.
- **The Documentation is... sparse**: Sometimes you will be reading a manual, and sometimes you will be reading 5-year-old Reddit threads praying for an answer.
- **Patience is key** (_or severe OCD tbh_): If you are not acquainted with the command line, programming languages, random crash logs, or want a computer that "just works" to play games or browse the web, consider yourself warned. Cuz this setup costs time, sanity, and the ability to casually refactor the codebase 2 minutes before a presentation.

# Still Reading?

If you really want to get dirty with Nix and decide to invest oodles of your time into building your own configuration, my [repository](https://github.com/maydayv7/dotfiles) can be used as inspiration.
You can check out the list of links below to resourceful Nix documentation/tutorials/projects that may be helpful in your endeavour, as they were in mine.

## Links

**See:** A [Curated List](https://github.com/nix-community/awesome-nix) of the Best Resources in the Nix Community  
**Also:** [This](https://nixos-and-flakes.thiscute.world/) website for beginners starting out with NixOS and Flakes

- Official [Documentation](https://nixos.org/learn.html)
- NixOS [Manual](https://nixos.org/manual/nixpkgs/stable)
- Nix [Pills](https://nixos.org/guides/nix-pills/)
- NixOS [Discourse](https://discourse.nixos.org/)
- NixOS [Package Search](https://search.nixos.org/)
- [`nixpkgs`](https://github.com/NixOS/nixpkgs) Package Repository
- [NUR](https://github.com/nix-community/NUR) Nix User Repository
- NixOS [Hardware Modules](https://github.com/nixos/hardware)
- Home Manager [Options](https://nix-community.github.io/home-manager/options.html)

### Other Sources

- Tweag [Article](https://www.tweag.io/blog/2020-05-25-flakes/) introducing Flakes
- Serokell's [Blog](https://serokell.io/blog/practical-nix-flakes) on Flakes
- Jordan Isaac's [Blog](https://jdisaacs.com/series/nixos-desktop/) for porting configuration to Flakes
- Jon Ringer's [Videos](https://www.youtube.com/channel/UC-cY3DcYladGdFQWIKL90SQ) on general NixOS Tooling and Hackery
- Justin's [Notes](https://github.com/justinwoo/nix-shorts) on using Nix
- Lan Tian's Series of [Blog Posts](https://lantian.pub/en/article/modify-website/nixos-initial-config-flake-deploy.lantian/) on NixOS
- Christine's [Blog Posts](https://christine.website/blog/series/nixos) addressing NixOS Security
- [Graham's](https://grahamc.com/blog/erase-your-darlings) and [Elis'](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/) Blog Posts on Ephemeral Partition Schemes

### Other Configurations

Here are some repositories that I may have shamelessly rummaged through for building my `dotfiles`:  
_Thanks a lot! ;)_

- [4JX](https://github.com/4JX/nixos-config)
- [balsoft](https://code.balsoft.ru/balsoft/nixos-config)
- [bbigras](https://github.com/bbigras/nix-config)
- [cole-h](https://github.com/cole-h/nixos-config/)
- [colemickens](https://github.com/cole-mickens/nixcfg)
- [davidtwco](https://github.com/davidtwco/veritas)
- [fufexan](https://github.com/fufexan/dotfiles)
- [gvolpe](https://github.com/gvolpe/nix-config)
- [hlissner](https://github.com/hlissner/dotfiles)
- [jordanisaacs](https://github.com/jordanisaacs/dotfiles)
- [kclejeune](https://github.com/kclejeune/system)
- [lovesegfault](https://github.com/lovesegfault/nix-config)
- [lucasew](https://github.com/lucasew/nixcfg)
- [nobbz](https://github.com/NobbZ/nixos-config)
- [rasendubi](https://github.com/rasendubi/dotfiles)
- [sioodmy](https://github.com/sioodmy/dotfiles)
- [tejing1](https://github.com/tejing1/nixos-config)
- [vlaci](https://github.com/vlaci/nixos-config)
- [wiltaylor](https://github.com/wiltaylor/dotfiles)
- [wimpysworld](https://github.com/wimpysworld/nix-config)

---

[^1]: [Meaning](http://gateway-drug.urbanup.com/2175521) ig

[^2]: [Arch Wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)

[^3]: T&C Apply ;)
