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
	#line-by-line[
	  Automatically rotate live frames so they are always displayed upright, independent of the actual camera orientation.
	  === Steps
	  - Record camera image
	  - Read orientation sensor
	  - Rotate image using FPGA
	  - Output rotated image
	]
	#pdfpc.speaker-note("selbst-gestellte Aufgabe: Live-Bild immer aufrecht halten, unabhängig von der Kamera")
]

#slide(title: "Architecture")[
	// #stack(dir: ltr, [== Architecture],align(left, image("architecture.png")))
	#set align(center)
	#image("architecture.png")
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

#slide(title: "Limitations")[
	#line-by-line[
	  - Only square picture (aspect ratio $1:1$)
	  - At most $<= 512*512$ pixels per image
	  - Rotation only in multiples of $plus.minus 90 degree$
	]
	#pdfpc.speaker-note(
    ```md
		Grenzen der Implementierung

		- mit 16:9 Bild: merkwürdige Artefakte im Bild -> Umgehen durch quadratischer Ausschnitt des Kamerabildes
		- vermutlich, weil Block-RAM erschöpft (Ein+Ausgabespeicher, je ca 2Mb bei 5,1Mb Block RAM) -> Ausschnitt des originalen Kamerabildes
		- `rotate` Operation in Xilinx Vision Bibliothek unterstützt nur das
    ```
  )
]

#slide(title: "Demo")[
	#set align(center)
	#link("https://cloud.erik-hennig.me/f/2486685", image("demo_still.png", height:87%))
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
