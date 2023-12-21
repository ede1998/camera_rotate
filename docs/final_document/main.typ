#import "template.typ": project

#show: project.with(
  title: "camera_rotate\n(Laborprojekt)",
  lecture: "Labor Rechnersysteme",
  logo: "resources/demo_still.png",
  authors: (
    (
      name: "Erik Alexander Hennig",
      email: "tae@erik-hennig.me", 
      affiliation: "Technische Akademie Esslingen", 
    ),
  ),
)

= Aufgabenstellung

Ziel des Laborprojekts ist die eigenständige Implementierung einer Bildverarbeitung in Hardware. Als Rahmenbedingung gegeben ist die Verwendung
des Kria KV260 Vision AI Starter Kits sowie die Nutzung der Xilinx Toolchain für High-Level-Synthese. Darüber hinaus ist die Wahl des Projekts
offen. In diesem Fall wurde als selbstgestellte Aufgabe gewählt, ein aufgenommenes Kamera-Bild unter Zuhilfenahme eines Orientierungssensors so
zu rotieren, dass es immer aufrecht angezeigt wird. Dabei soll die Rotation performant genug sein, um ein flüssiges Live-Bild anzuzeigen.

= Implementierung

Um das Performance-Ziel zu erreichen, soll die Rotation des aufgenommenen Bilds in Hardware implementiert werden. Die übrige Logik wird nur in
Software implementiert. @img:arch zeigt die architekturelle Umsetzung des Projekts. Der Mikrocontroller-Baustein in der Mitte stellt den
nicht-programmierbaren Teil des Kria-Boards dar. Dieser kommuniziert mit dem FPGA-Teil via AXI und AXI-Lite. Die Aufnahme des (verdrehten)
Live-Bilds erfolgt mit einer per USB angeschlossenen Webcam. Zur Bestimmung der Kameraorientierung wird ein modernes Smartphone genutzt. Solche
Geräte verfügen in der Regel alle über einen Orientierungsensor und sind leicht zu integrieren, da sie über zahlreiche Wege kommunizieren können.
Das Smartphone wird mittels einiger Gummibänder mechanisch an die Webcam gekoppelt, sodass beide die gleiche räumliche Orientierung aufweisen.
Zum Auslesen der aktuellen Orientierung implementiert das Programm auf dem Kria-Board in einem extra Thread einen minimalistischen Webserver. Der
in der Website enthaltene Javascript-Code liest den Orientierungssensor des Smartphones aus und sendet ihn per HTTP zurück zum Webserver. Anhand
der erhaltenen Orientierung kann dann das Kamerabild auf dem FPGA um die passende Gradzahl rotiert werden. Die Ausgabe des Bildes erfolgt per HDMI
auf einem externen Display oder per SSH mittels X11 Display Forwarding auf einem weiteren PC.

#figure(
  image("resources/architecture.png"),
  caption: "Kommunikationskanäle"
) <img:arch>

Zur Umsetzung der Rotation in Hardware kommen folgende Funktionen der Vitis Vision Library auf den ersten Blick in Betracht:

- `remap` @vision-remap: vertauscht Pixel anhand einer Relokationsmatrix
- `warpTransform` @vision-wtf: wendet eine affine Transformation auf das Eingangsbild an
- `rotate` @vision-rotate: rotiert das Eingangsbild um 90, 180 oder 270 Grad

Die ersten beiden Funktionen erlauben eine beliebige Rotationen. Allerdings sind sie nicht ganz so trivial zu verwenden wie `rotate`, das explizit
nur für die Rotation implementiert wurde. Aus diesem Grund wurde `rotate` für die erste Implementierung genutzt und dann aus Zeitgründen auch nicht
mehr ersetzt.

== Parameter

=== Pragmas

Die Argument für `rotate` wurden größtenteils einfach durchgereicht. Dabei wurde die Übergabe kleiner Argumente per AXI-Lite umgesetzt. Dies
betrifft die tatsächliche Breite und Höhe des Bilds, den Rotationswinkel und die Steuerung des IP-Blocks. Die Übertagung der Eingabe- und
Ausgabe-Bilddaten erfolgt über einen AXI-Bus. Dabei wurden folgende Parameter gewählt:

- `offset=slave`: Die Vitis-Dokumentation schreibt diesen Wert vor @vitis-axi-offset-mode
- `depth=__XF_DEPTH`: Repräsentiert die Größe des Adressbereichs @vitis-axi-offset-mode, also die maximale Größe des Bilds in Bytes
  ($= "Höhe" * "Breite" * "Kanäle" * "Kanalbreite" = 512 * 512 * 1 * 1 = 262144$)
- `bundle=gmem0`/`bundle=gmem1`: Eingabe- und Ausgabebild werden über getrennte Bundles übertragen, um Performance-Einbüßen zu vermeiden
  @vitis-axi-bundle. 

Die Auflistung der `INTERFACE`-Pragmas sieht somit folgendermaßen aus:

```cpp
#pragma HLS INTERFACE mode=s_axilite port=rows
#pragma HLS INTERFACE mode=s_axilite port=cols
#pragma HLS INTERFACE mode=s_axilite port=direction
#pragma HLS INTERFACE mode=s_axilite port=return

#pragma HLS INTERFACE mode=m_axi depth=__XF_DEPTH bundle=gmem0 port=src_ptr offset=slave
#pragma HLS INTERFACE mode=m_axi depth=__XF_DEPTH bundle=gmem1 port=dst_ptr offset=slave
```

=== `INPUT_PTR_WIDTH`, `OUTPUT_PTR_WIDTH` und `TYPE`

Der Template-Paramter `TYPE` gibt die Anzahl an (Farb-)Kanälen und die Bitbreite eines Kanals an. `INPUT_PTR_WIDTH` und `OUTPUT_PTR_WIDTH` geben
ebenfalls die Breite eines einzelnen Eingabe- bzw. Ausgabepixels in Bit an. Unglücklicherweise klärt die Dokumentation die Dopplung im Pixelformat
und daraus die resultierende Einschränkungen nicht auf. Mit den Werten `INPUT_PTR_WIDTH=OUTPUT_PTR_WIDTH=8` und `TYPE=XF_8UC1` wird die Funktion
korrekt ausgeführt, aber andere Kombinationen führen bereits in der C-Simulation zu Segmentierungsverletzungen und Assertion-Fehlern, z.B.
`INPUT_PTR_WIDTH=8`, `OUTPUT_PTR_WIDTH=16`, `TYPE=XF_8UC1`. Die Nutzung von 3-Kanal-Farbbildern mit `TYPE=XF_8UC3` scheint ebenfalls nicht möglich.
Bei einer Eingabe-/Ausgabebreite von 8 Bit ergibt sich ein Assertionfehler und 24 Bit sind bereits laut Dokumentation untersagt, da nur
2er-Potenzen erlaubt sind.

=== `COLS` und `ROWS`

Diese Template-Parameter geben die Maximalbreite und -höhe des zu drehenden Bildes in Pixel an. Diese sind in einem gewissen Rahmen frei-wählbar,
allerdings muss bei nicht-quadratischen Bildern darauf geachtet werden, die Maße des Ausgabebildes abhängig von der Rotation anzupassen.
Andernfalls werden die Pixel durch fehlerhaft Interpretation der Pixelposition an der falschen Stelle dargestellt wie in @img:rect-image zu sehen.

#figure(
  columns(3)[
    #image("resources/rect-image-0.png")
    #colbreak()
    #image("resources/rect-image-90.png", width: 70%)
    #colbreak()
    #image("resources/rect-image-err.png")
  ],
  caption: "Rotation eines nicht-quadratischen Bildes"
) <img:rect-image>

Geringe max size

300x200

All the functions in the library are implemented in streaming model except 4. Crop, EdgeTracing, MeanShiftTracking, Rotate are memory mapped implemenations. These functions need to have the flag `__SDA_MEM_MAP__` set for compiling correctly
https://xilinx.github.io/Vitis_Libraries/vision/2022.1/api-reference.html#id99


=== `NPC` und `TILE_SIZE`

== Probleme

=== Rotation um 0 Grad

=== Dokumentation

Die Dokumentation der Vitis Vision Library hat an einigen Stellen zu Problemen geführt. Beispielsweise beschreibt sie, welcher Header für welche
Funktion zu inkludieren ist, separat und für manche Funktionen, wie z.B. die genutzte `xf::cv::rotate`, fehlt ein Eintrag @vitis-headers. Somit
war nicht direkt ersichtlich, was der korrekte Header ist. Ein weiteres Problem war die fehlerhafte Dokumentation von `rotate`. Als erlaubte Werte
für den `direction` Parameter werden explizit 90, 180 und 270 genannt @vision-rotate. Bei Aufruf mit diesen Parameter ergibt sich jedoch immer eine
Rotation um 90 Grad. Nach einiger Suche im Quellcode der Vision Library findet sich die schuldige Codestelle:

```cpp
// xf_rotate.hpp:69
for (int k = 0; k < NPC; k++) {
	#pragma HLS UNROLL
	if(direction == 0){
    // rotation by 270 degrees
	}
	else if(direction == 1){
    // rotation by 180 degrees
	}
	else {
    // rotation by 90 degrees
	}
}
```

Somit sind die korrekten Parameter-Werte nicht 90, 180 und 270, sondern 2, 1 und 0, was der Dokumentation widerspricht. Mit diesen neuen Werte
funktioniert die Rotation in eine beliebige der drei möglichen Richtungen.

= Performance

= Fazit

- viel gelernt
- Doku könnte besser sein
- persönlich: hat Spaß gemacht
- performance? measure first? oder HW ist schnell

Die vollständige Implementierung des Projekts findet sich unter https://github.com/ede1998/camera_rotate @project-impl.

#pagebreak(weak: true)
#set page(header: [])
= Bibliographie

#bibliography("bibliography.bib", title: none)
