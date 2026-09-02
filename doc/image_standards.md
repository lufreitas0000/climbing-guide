# Climbing Guide Image Standards (V1.9)

## Print Geometry Baseline
* **Paper Width (with bleed):** 150mm
* **Paper Height (with bleed):** 210mm
* **Text Width (10mm margins):** 130mm
* **Target Density:** 300 DPI (11.81 px/mm)
* **Color Space:** sRGB (converted to CMYK at print rip)

## Pre-Scaling Targets

1. **Zone Covers (\CGZoneHeader)**
   * **Dimensions:** 1800 x 750 pixels
   * **Ratio:** 2.4 : 1
   * **Note:** Fits the `\CGZoneBannerHeight` exactly.

2. **Full Page Overlays (\CGOverlayImage)**
   * **Dimensions:** 1800 x 2500 pixels
   * **Ratio:** 1 : 1.4
   * **Note:** Images will crop centrally if ratios do not match.

3. **Full Width Topos (\CGFullWidthImage)**
   * **Dimensions:** 1600 x Auto (Max 2000 height)
   * **Note:** Maps exactly to the 130mm `\textwidth`.

4. **Half Width & Column Topos (\CGHalfWidthImage, \CGRouteImageRight)**
   * **Dimensions:** 800 x Auto
   * **Note:** Maps to the 48% column width constraint.

## Formats
* Use **JPEG (Quality 85-90)** for high-frequency photography.
* Use **PNG-24** for vector-heavy diagrams or topos requiring sharp line transitions.
