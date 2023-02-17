---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.13.6
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

# Inverter Sample

```
Copyright 2023 Google LLC.
SPDX-License-Identifier: Apache-2.0
```

This notebook shows how to run a simple inverter design thru an end-to-end RTL to GDSII flow targetting the [SKY130](https://github.com/google/skywater-pdk/) process node.

## Write verilog

Invert the `in` input signal and continuously assign it to the `out` output signal.

```python
%%bash -c 'cat > inverter.v; iverilog inverter.v'
module inverter(input wire in, output wire out);
    assign out = !in;
endmodule
```
## Write OpenLane configuration

See [OpenLane Variables information](https://github.com/The-OpenROAD-Project/OpenLane/blob/master/configuration/README.md) for the list of available variables.

```python
%%bash -c 'cat > config.tcl; tclsh config.tcl'
set ::env(DESIGN_NAME) inverter

set ::env(VERILOG_FILES) "inverter.v"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 50 50"
set ::env(PL_TARGET_DENSITY) 0.75

set ::env(CLOCK_TREE_SYNTH) 0
set ::env(CLOCK_PORT) ""
set ::env(DIODE_INSERTION_STRATEGY) 0
```

## Run OpenLane flow

[OpenLane](https://github.com/The-OpenROAD-Project/OpenLane) is an automated RTL to GDSII flow based on several components including [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD), [Yosys](https://github.com/YosysHQ/yosys), [Magic, Netgen, Fault, CVC, SPEF-Extractor, CU-GR, Klayout and a number of custom scripts for design exploration and optimization.

```python tags=[]
!flow.tcl -design . -ignore_mismatches
```

## Display layout with GDSII Tool Kit

[Gdstk](https://github.com/heitzmann/gdstk) (GDSII Tool Kit) is a C++/Python library for creation and manipulation of GDSII and OASIS files.

```python
import pathlib
import gdstk
from IPython.display import SVG

gds = sorted(pathlib.Path('runs').glob('*/results/final/gds/*.gds'))[0]
library = gdstk.read_gds(gds)
top_cells = library.top_level()
top_cells[0].write_svg('inverter.svg')
SVG('inverter.svg')
```
