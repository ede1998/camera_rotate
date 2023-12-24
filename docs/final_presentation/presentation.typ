#import "@preview/polylux:0.3.1": *

#import themes.clean: *

#set text(font: "Source Sans 3")

#show: clean-theme.with(
	footer: [camera_rotate - Erik Hennig],
)

#title-slide(
	authors: "Erik Hennig",
	title: [camera_rotate],
	subtitle: [Lab Project],
	date: "2023-11-29",
)

#slide(title: "Task")[
	Automatically rotate live frames so they are always displayed upright, independent of the actual camera orientation.
	#pdfpc.speaker-note("selbst-gestellte Aufgabe: Live-Bild immer aufrecht halten, unabhängig von der Kamera")
]

#slide(title: "Architecture")[
	// #stack(dir: ltr, [== Architecture],align(left, image("architecture.png")))
	#set align(center)
	#image("resources/architecture.png")
	#pdfpc.speaker-note(
    ```md
		- Programm auf Kria Prozessor
		- 2 Threads: Kamera-Bild verarbeiten, HTTP-Server hosten
		- Smartphone öffnet Website, JS liest Orientierungssensor aus, sendet Wert
		- Kamera nimmt verdrehtes Bild auf
		- aktueller Orientierungswert wird mit Bild dem FPGA übergeben
		- Rotation des Bildes
		- Ausgabe des Bildes in korrekter Orientierung
    ```
  )
]

#slide(title: "HLS function")[
	- Only image rotation itself in HLS
	- candidate function from Vitis Vision Library:
    - `remap`: swaps pixels using a relocation matrix
    - `warpTransform`: applies affine transformations to image
    - *`rotate`: rotates an image by 90, 180 or 270 degrees*
	#pdfpc.speaker-note(
    ```md
		- remap + warpTransform -> sollte beliebige Rotation erlauben
		- nicht so trivial zu nutzen (passende Matrix)
		-> rotate als Startpunkt und aus Zeitgründen auch behalten
    ```
  )
]

#slide(title: "HLS function")[
	```cpp
	void krnl_vadd(Pixel *src_ptr, Pixel *dst_ptr, uint16_t rows, uint16_t cols, uint16_t direction) {
    #pragma HLS INTERFACE mode=s_axilite port=rows
    #pragma HLS INTERFACE mode=s_axilite port=cols
    #pragma HLS INTERFACE mode=s_axilite port=direction
    #pragma HLS INTERFACE mode=s_axilite port=return
    #pragma HLS INTERFACE mode=m_axi depth=__XF_DEPTH bundle=gmem0 port=src_ptr offset=slave
    #pragma HLS INTERFACE bundle=gmem1 port=dst_ptr // ...
	```
	#pdfpc.speaker-note(
    ```md
		- AXI-Lite für kleine Parameter -> Ressourcen schonen
		- Bilddaten selbst per AXI, aber am Ende hat sich gezeigt: `rotate` nutzt mmap also vermutlich Bilddaten gar nicht übertragen
		-> AXI-Lite hätte auch gereicht.
	  ```
	)
]

#slide[
	```cpp
    const auto rotation = determine_rotation(direction);
    
    if (rotation == None) {
    	for (uint32_t i = 0; i < rows * cols; ++i) {
    		dst_ptr[i] = src_ptr[i];
    	}
		} else {
    	xf::cv::rotate<BITS_PER_PIXEL, BITS_PER_PIXEL, XF_8UC1, 32, MAX_ROWS, MAX_COLS, XF_NPPC1>(src_ptr, dst_ptr, rows, cols, rotation);
		}}
	```
	#pdfpc.speaker-note(
    ```md
		- `determine_rotation` mapped den Winkel in Grad -> Enum Wert
		- rotate erwartet 0,1,2 als Rotationsparameter
		- rotate rotiert immer. Rot um 0 Grad nicht möglich -> manuell dazugebaut per for-Schleife, somit einfache Implementierung des SW-Programms
    ```
  )
]

#slide(title: "Parameter")[
  `xf::cv::rotate<`#highlight(fill: red)[IN_WIDTH,OUT_WIDTH,TYPE,]#highlight(fill: green, uncover("3-")[TILE_SZ,])#highlight(fill: blue, uncover("2-")[ROWS,COLS,])#highlight(fill: green, uncover("3-")[NPC])
	`>`

	/ #highlight(fill: red, [`INPUT_PTR_WIDTH,OUTPUT_PTR_WIDTH,TYPE`]): Tried different combinations, only `8,8, XF_8UC1` worked
	#uncover("2-")[/ #highlight(fill: blue, [`ROWS,COLS`]): <= 515x515px (otherwise `SEGFAULT` in co-sim), careful with non-square images]
	#uncover("3-")[/ #highlight(fill: green, [`TILE_SZ,NPC`]): *TODO*]
	#pdfpc.speaker-note(
    ```md
		- WIDTH,TYPE: Eingabe/Ausgabe-Bitbreite eines Pixels und Pixel-Format (Kanäle, Bitbreite), unklar: mögliche Inkonsistenz?
		- COLS/ROWS: Fehlerursache unklar, max mit bin. Suche gefunden. Bei nicht quadratischen Bilder und Rot um 90/270:
		  Achtung Seitenlängen vertauschen, sonst Pixel an falscher Position
		```
	)
]

#slide(title: "Ressource Usage and Performance")[
	*TODO*
	- Ressource usage ($<10%$)independent from `COLS`/`ROWS`
	#pdfpc.speaker-note(
    ```md
		- Grund: Memory Map
		```
	)
]

#slide(title: "Problems")[
	#one-by-one[
		- Wrong documentation of Vitis Vision Library
		  - "Direction of rotate, possible values are 90, 180 or 270"
			- ```cpp if (direction == 0) {} else if (direction == 1) {} else {}```
	][
		- Missing documentation of Vitis Vision Library
		  - no include directive given for `xf::cv::rotate`
	][
		- Bad error messages
		  - `INPUT_PTR_WIDTH` must be power of two #sym.arrow weird run-time errors
			- `SEGFAULT` in co-sim when `COLS`/`ROWS` too large
	]
]

#slide(title: "Demo")[
	#set align(center)
	#link("./resources/demo.mp4", image("resources/demo_still.png", height:87%))
	#pdfpc.speaker-note(
    ```md
		- Website noch nicht geladen, Applikation noch nicht gestartet
		- Start Applikation
		- Website immer noch nicht geladen
		- Kamera wird rotiert, keine Sensor-Daten -> Bild rotiert mit
		- Website wird geladen -> Orientierung wird angezeigt und versendet
		- Kamera wird rotatiert -> Bild wird nie schiefer als 45 Grad
    ```
  )
]

#new-section-slide("Thank you for your attention!")
