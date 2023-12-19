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

== Implementierung

Um das Performance-Ziel zu erreichen, soll die Rotation des aufgenommenen Bilds in Hardware implementiert werden. Die übrige Logik wird nur in
Software implementiert. #ref(<img:arch>) zeigt die architekturelle Umsetzung des Projekts. Der Mikrocontroller-Baustein in der Mitte stellt den
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


- Welcher Teil genau in Hardware?
- Welche HW-Funktion kommt in Betracht?
- Implementierung der Hw-Funktion

=== Parameter-Variation

=== Probleme

== Performance

== Fazit

- viel gelernt
- Doku könnte besser sein
- persönlich: hat Spaß gemacht
- performance? measure first? oder HW ist schnell

#pagebreak(weak: true)
#set page(header: [])
= Bibliographie
#lorem(30)
