# svg2stl
this tool converts SVG to STL, which then can be loaded into any slicer and 3D printed.
- preserves the quality of image (to some extent)
- fixes SVG by redrawing it from rasterized version
- can create negatives

## how to
this manual is indented for making PCB on a DLP resin printer, but you may use it however you like.

### pcb editor
KiCad PCB Editor / EasyEDA / Altium / etc:

1. 
    Edge Cuts layer: draw a rectangle with dimensions of your DLP printing area.
    - Anycubic Photon Ultra = 102.4x57.6mm
    - Anycubic Photon Mono = 130x80mm

2.
    Export SVG with traces (F.Cu)
    - color: black and white
    - page size: board area only

### svg2stl
```console
git clone https://github.com/MikeWent/svg2stl
cd svg2stl
docker comopse up -d
```

then open: http://localhost:8044 and upload your file

### slice & print
simply load STL into any slicer, such as Photon Workshop.

## license
MIT
