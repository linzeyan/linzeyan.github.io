---
title: "Data Center Notes"
date: 2017-10-24T23:17:33+08:00
menu:
  sidebar:
    name: "Data Center Notes"
    identifier: network-idc-network-center-notes
    weight: 10
tags: ["Network"]
categories: ["Network"]
hero: images/hero/network.png
---

First NIC - blue cable

Second NIC - green cable

Switch interconnect - white cable

Yellow, red

Storage has disk arrays and heavy data transfer, so it uses fiber connections and fiber switches.

Fiber colors:

Multi-mode or single-mode fiber

Single-mode fiber is yellow. Multi-mode fiber (50μm or 62.5μm) is usually orange. 10GB multi-mode fiber is usually aqua.

Common spec distinctions:

- OS1, OS2, 9µm, 9/125 = single-mode fiber
- OM1, 62.5µm, 62.5/125 = 62.5 multi-mode fiber
- OM2, 50µ, 50/125 = 50 multi-mode fiber
- OM3, 10GB, 50µm, 50/125 = 10GB multi-mode fiber
- OM4, 100GB, 50µm, 50/125 = 100GB multi-mode fiber

Fiber structure

Bare fiber consists of three layers:

- Core: high-refractive-index glass core (typically 9μm for single-mode, 50 or 62.5μm for multi-mode).
- Cladding: low-refractive-index silica (diameter 125μm).
- Coating: reinforcing resin coating (diameter 250μm).

Fiber types

1. Based on transmission modes by wavelength: single-mode fiber and multi-mode fiber.
   1. Multi-mode fiber: the center glass core is thicker (50 or 62.5μm), the cladding is 125μm, and it can transmit multiple modes. But modal dispersion is larger, limiting the signal frequency, and becomes worse with distance. For example, a 600MB/KM fiber at 2KM only has 300MB bandwidth. Therefore, multi-mode fiber is used over shorter distances, usually only a few kilometers.
   2. Single-mode fiber: the center glass core is thinner (typically 9 or 10μm) and carries only one mode. Modal dispersion is very small, suitable for long-distance communication, but chromatic dispersion dominates, so it requires a narrow spectrum and a stable light source.
2. By optimal transmission window: conventional single-mode fiber and dispersion-shifted single-mode fiber.
   1. Conventional: optimized for a single wavelength, such as 1300μm.
   2. Dispersion-shifted: optimized for two wavelengths, such as 1300μm and 1550μm.
3. By refractive-index profile: step-index and graded-index fiber.

Common fiber specs

- Single-mode fiber: 8/125μm, 9/125μm, 10/125μm
- Multi-mode fiber: 50/125, European standard 62.5/125μm, US standard industrial/medical/low-speed networks: 100/140μm, 200/230μm
- Plastic fiber: 98/1000μm, used for automotive control.

First rack - network rack: firewall, core switch, lots of cables.

Servers have many fans, can be placed close together; cooling is better, usually placed lower.

Network devices should be spaced at least 1U to avoid overheating, usually placed on top.

The data center AC blows upward; devices face this side.
