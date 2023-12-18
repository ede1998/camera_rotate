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
#lorem(60)

== Implementierung
#lorem(20)

=== Architektur
#lorem(40)
#parbreak()
#lorem(30)

=== Parameter-Variation

=== Probleme

== Performance

#lorem(500)
#lorem(500)

== Fazit
#lorem(100)
#figure(
  image("resources/demo_still.png", width: 70%),
  caption: "Serious Business."
)

// Bibliography section
#pagebreak(weak: true)
#set page(header: [])
= Bibliography
#lorem(30)
