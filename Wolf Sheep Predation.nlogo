;;shooting-range ads-time parametre
globals [ max-sheep coordonnees hunting-zone-x1 hunting-zone-y1 hunting-zone-x2 hunting-zone-y2 shooting-range ads-time]


breed [ sheep a-sheep ]
breed [ promeneurs a-promeneur]
breed [ wolves a-wolf]

turtles-own [ energy evade_mode]
patches-own [ countdown visit-count]

promeneurs-own [direction vitesse ]

wolves-own [aiming cible]


to setup
  clear-all
  ifelse netlogo-web? [ set max-sheep 10000 ] [ set max-sheep 30000 ]
  set shooting-range 15
  set ads-time 10

  ; Initialisation des patches (fond vert)
  ask patches [
    set pcolor green
    set countdown random 50
    set visit-count 0
  ]

  create-path  ; Créer le chemin
  show coordonnees
  draw-hunting-zone  ; Dessiner le cadre rouge



  create-sheep initial-number-sheep [
  set shape "sheep"
  set color white
  set size 1.5
  set label-color blue - 2
  set energy random 4000 + 1000
  setxy random-float (hunting-zone-x2 - hunting-zone-x1) + hunting-zone-x1
        random-float (hunting-zone-y2 - hunting-zone-y1) + hunting-zone-y1
  ifelse show-energy = true [
    set label (round (energy * 100) / 100)
  ] [
    set label ""
  ]


  create-wolves initial-number-wolf [
    set shape "wolf"
    set color black
    set size 1.5
    set label-color blue - 2
    set energy random 4000 + 1000
    set aiming 0
    set cible sheep
    setxy random-xcor random-ycor
    setxy random-float (hunting-zone-x2 - hunting-zone-x1) + hunting-zone-x1 random-float (hunting-zone-y2 - hunting-zone-y1) + hunting-zone-y1
    ifelse show-energy = true[
      set label (round (energy * 100) / 100)
    ]
    [
     set label ""
    ]
  ]
  ask wolves[
    create-links-with sheep[
      set color red
      hide-link
    ]
  ]

  create-promeneurs initial-number-promeneurs [
    set shape "person"
    set color blue
    set size 2
    set energy random 4000 + 1000
    set direction random 2
    set vitesse precision (0.2 + random-float 0.4) 2
    let x1 item 0 item 0 coordonnees
    let y1 item 1 item 0 coordonnees
    let x2 item 0 item 1 coordonnees
    let y2 item 1 item 1 coordonnees

    ; Placer la tortue sur la première ou la deuxième coordonnée
    ifelse direction = 0 [
      setxy x1 y1
    ]
    [
      setxy x2 y2
    ]
    ; Afficher l'énergie si nécessaire
    ifelse show-energy = true [
      set label (round (energy * 100) / 100)
    ]
    [
      set label ""
    ]
  ]


  reset-ticks
end



to go
  if not any? sheep [ stop ]

  ; Vérifier si un nouveau promeneur doit être ajouté
  if ticks mod 500 = 0 [
    ifelse random 1000 = 0[
      create-promeneurs 100 [
        set shape "person"
        set color blue
        set size 2
        set energy random 4000 + 1000
        set direction random 2
        set vitesse precision (0.2 + random-float 0.3) 1
        let x1 item 0 item 0 coordonnees
        let y1 item 1 item 0 coordonnees
        let x2 item 0 item 1 coordonnees
        let y2 item 1 item 1 coordonnees

        ; Placer la tortue sur la première ou la deuxième coordonnée
        ifelse direction = 0 [
          setxy x1 y1
        ]
        [
          setxy x2 y2
        ]
        ; Afficher l'énergie si nécessaire
        ifelse show-energy = true [
          set label (round (energy * 100) / 100)
        ]
        [
          set label ""
        ]
    ]
    ]
    [
    create-promeneurs 1 [
        set shape "person"
        set color blue
        set size 2
        set energy random 4000 + 1000
        set direction random 2
        set vitesse precision (0.2 + random-float 0.3) 1
        let x1 item 0 item 0 coordonnees
        let y1 item 1 item 0 coordonnees
        let x2 item 0 item 1 coordonnees
        let y2 item 1 item 1 coordonnees

        ; Placer la tortue sur la première ou la deuxième coordonnée
        ifelse direction = 0 [
          setxy x1 y1
        ]
        [
          setxy x2 y2
        ]
        ; Afficher l'énergie si nécessaire
        ifelse show-energy = true [
          set label (round (energy * 100) / 100)
        ]
        [
          set label ""
        ]
    ]
  ]
  ]

  ask sheep [
    move-sheep
    death
    ifelse show-energy = true[
      set label (round (energy * 100) / 100)
    ]
    [
      set label ""
    ]
  ]

  ask wolves [
    move-wolves
    death
    ifelse show-energy = true[
      set label (round (energy * 100) / 100)
    ]
    [
      set label ""
    ]
  ]

  ask promeneurs [
    move-promeneurs
    death
    ifelse show-energy = true[
      set label (round (energy * 100) / 100)
    ]
    [
     set label ""
    ]
  ]

  ; Logique de repousse de l'herbe
  ask patches [
;    if pcolor = brown [
;      set countdown countdown - 1
;      if countdown <= 0 [
;        set pcolor green
;      ]
;    ]
    let x1 item 0 item 0 coordonnees
    let y1 item 1 item 0 coordonnees
    let x2 item 0 item 1 coordonnees
    let y2 item 1 item 1 coordonnees
    if (pxcor = x1 and pycor = y1) or (pxcor = x2 and pycor = y2)[
     set pcolor black
    ]
  ]

  tick
end




to move-promeneurs
  ; Récupérer les coordonnées du chemin
  let x1 item 0 item 0 coordonnees
  let y1 item 1 item 0 coordonnees
  let x2 item 0 item 1 coordonnees
  let y2 item 1 item 1 coordonnees

  ; Vérifier si le promeneur est à côté d'une tortue "stop-sign"
  ifelse any? turtles-here with [shape = "tree"] [
    if random-float 1 <= 0.95 [ ; 95 % des cas
      set direction 1 - direction ; Faire demi-tour
      fd vitesse * 3 ; Avancer dans la nouvelle direction
      stop ; Ne pas continuer d'autres actions
    ]
  ][
    ; Déterminer la direction normale du promeneur
    ifelse direction = 0 [
      ifelse x2 = pxcor and y2 = pycor [
        ; Si le promeneur atteint la fin du chemin, changer de direction
        set direction 1 - direction
      ][
        ; Avancer vers la fin du chemin
        set heading towardsxy x2 y2
      ]
    ] [
      ifelse x1 = pxcor and y1 = pycor [
        ; Si le promeneur atteint le début du chemin, changer de direction
        set direction 1 - direction
      ][
      ; Avancer vers le début du chemin
        set heading towardsxy x1 y1
      ]
    ]
  ]

  ; Déplacement normal
  fd vitesse

  ; Consommer de l'énergie
  set energy energy - 1
end


to move-sheep
  let nearby-wolves wolves in-radius 5 ; Loups proches dans un rayon de 5 unités
  ifelse any? nearby-wolves [
    ; Calculer le centre des loups proches
    let wolf-center mean [xcor] of nearby-wolves
    let wolf-center-y mean [ycor] of nearby-wolves

    ; Calculer la direction opposée
    if xcor = min-pxcor or xcor = max-pxcor or ycor = min-pycor or ycor = max-pycor[
      face patch (2 * xcor - wolf-center) (2 * ycor - wolf-center-y)
    ]
    fd 1 ; Fuir dans la direction opposée
  ] [
    ; Comportement aléatoire s'il n'y a pas de loups
    let new-heading heading + random 50 - random 50
    set heading new-heading
    fd 1
  ]

  ; Empêcher le mouton de quitter les zones marron
  ifelse pcolor = brown and any? nearby-wolves [
    ifelse random 10 != 0 [
      bk 1
      if evade_mode = false[
        set heading heading + 180
      ]
      fd 1
    ][
     set evade_mode true
    ]
  ][
    set evade_mode false
  ]
  if pxcor = min-pxcor or pxcor = max-pxcor or pycor = min-pycor or pycor = max-pycor [
    bk 1
    set heading heading + 180
    fd 1
  ]
  set energy energy - 0.5 ; Réduction de l'énergie
end

to-report is-los-clear? [radius]
  ;; Initialiser une liste pour les agents détectés
  let los-clear true
  let cibles []
  let cibles-set sort turtles in-radius radius with [self != myself and not is-a-sheep? self]
  set cibles cibles-set
  ;; Examiner chaque tortue dans le rayon, en excluant la tortue appelante
  foreach cibles [t ->
    ;show cibles
    ;let me-self myself
    ;; Obtenir une référence explicite à l'agent appelant
    ;; Calculer l'angle relatif entre l'agent actuel et l'agent appelant
    let relative-angle subtract-headings (towards t) heading

    ;; Vérifier si l'agent est dans l'arc spécifié
    ;show "angles"
    ;show is-a-sheep? self
    ;show relative-angle
    ;show abs relative-angle + 60
    ;if is-a-sheep? = false[
    if (relative-angle >= 0 and relative-angle - 60 <= 0) or (relative-angle <= 0 and relative-angle + 60 >= 0)[
        ;; La ligne de tir n'est pas dégagée
        ;;ask me-self [
        ;;set los-clear lput self los-clear
        ;;]
        ;; Marquer visuellement les agents détectés
      ;show t
      ;show relative-angle
      report false

    ]
    ;]
  ]

  ;; Afficher la liste des agents détectés par l'agent appelant
  ;show word "Tir possible : " los-clear
  report true
end

to-report shoot-hit?
  let x1 xcor
  let y1 ycor
  let x2 [xcor] of cible
  let y2 [ycor] of cible
  let absx abs (x2 - x1)
  let absy abs (y2 - y1)
  let steps max list absx absy ;; Nombre d'étapes nécessaires pour tracer la ligne

  ;; Diviser le segment en petites étapes
  let x-step (x2 - x1) / steps
  let y-step (y2 - y1) / steps

  ;; Vérifier chaque patch traversé
  let target-color green
  foreach range steps [i ->
    ;show i
    let x (x1 + x-step * i)
    let y (y1 + y-step * i)
    if [pcolor] of patch (round x) (round y) = target-color [
      ;show (word "Patch " target-color " trouvé à (" round x ", " round y ")")

    ]
  ]
  report true
end

to move-wolves
  let closest-sheep min-one-of (sheep in-radius 30) [distance myself] ; Trouver le mouton le plus proche
  let nearby-wolves other wolves in-radius 2 ; Loups proches dans un rayon de 2 unités, sauf soi-même

  ; Chasser le mouton ou se déplacer aléatoirement
  if closest-sheep != nobody [
    face closest-sheep ; Se diriger vers le mouton le plus proche

    ; Manger le mouton s'il est suffisamment proche
    if distance closest-sheep < shooting-range [

      ifelse aiming = 0 [
        ; Mise en joue
        set cible closest-sheep
        face cible
        ask cible [
          set color blue
        ]
        set aiming ticks
        ; print "Début aiming"
        ; print ticks
      ][
        ifelse not is-agent? cible[
          set aiming 0
        ][
          face cible
          ifelse is-los-clear? (shooting-range * 2) = true[
            if distance cible <= shooting-range[
              ; Mise en joue terminée, la cible est-elle toujours à portée?
              if ticks > aiming + ads-time[
                ; Cible toujours à portée
                if shoot-hit?[
                  ask link-with cible[
                    show-link
                  ]
                  display
                  wait 1
                  ask cible [ die ]  ; Manger le mouton
                  set energy energy + 500    ; Augmenter l'énergie
                ]
              ]
            ]
          ][
            ask cible [ set color white]
            set aiming 0
          ]
        ]
      ]
    ]
  ]

  ; Éviter les autres loups s'ils sont trop proches
  if any? nearby-wolves [
    let closest-wolf min-one-of nearby-wolves [distance myself] ; Loup le plus proche
    if closest-wolf != nobody [
      ; Tourner de 30° dans la direction opposée au loup le plus proche
      let angle-to-closest-wolf towards closest-wolf
      rt 30 - (angle-to-closest-wolf - heading) ; Tourner de 30° dans la direction opposée
    ]
  ]

  ; Vérifier si le patch sous le loup est rouge
  ifelse pcolor = red [
    bk 1 ; Reculer légèrement
    set heading heading + 180 ; Faire demi-tour
    fd 1 ; Avancer après demi-tour
  ]
  [
    fd 0.5 ; Sinon avancer normalement
  ]

  ; Éviter de sortir des limites du monde
  if pxcor = min-pxcor or pxcor = max-pxcor or pycor = min-pycor or pycor = max-pycor [
    bk 1
    set heading heading + 180
    fd 1
  ]

  set energy energy - 0.5 ; Réduction de l'énergie à chaque mouvement
end



;to reproduce-if-touching
;  let mates other sheep-here
;  if any? mates [
;    if random-float 100 < sheep-reproduce [
;      set energy energy * 8 / 10
;      hatch 1 [ rt random-float 360 fd 1 ]
;    ]
;  ]
;end

to death
  if energy <= 0 [ die ]
end





;
;
;
;  fonction pour la création du plateau/ de la carte
;
;
;


to create-path
  let path-choice random 2 + 1

  let start-patch 0
  let end-patch 0

  if path-choice = 1 [
    ; Utiliser les bords gauche et droit
    set start-patch one-of patches with [pxcor = min-pxcor]
    set end-patch one-of patches with [pxcor = max-pxcor]
  ]
  if path-choice = 2 [
    ; Utiliser les bords supérieur et inférieur
    set start-patch one-of patches with [pycor = min-pycor]
    set end-patch one-of patches with [pycor = max-pycor]
  ]

  ; Empêcher que start-patch et end-patch soient les mêmes
  while [ start-patch = end-patch ] [
    if path-choice = 1 [
      set end-patch one-of patches with [pxcor = max-pxcor]
    ]
    if path-choice = 2 [
      set end-patch one-of patches with [pycor = max-pycor]
    ]
  ]
  let x1 [pxcor] of start-patch
  let y1 [pycor] of start-patch
  let x2 [pxcor] of end-patch
  let y2 [pycor] of end-patch

  ifelse (x1 <= max-pxcor and y1 <= max-pycor and
         x2 <= max-pxcor and y2 <= max-pycor) [
    set coordonnees (list (list x1 y1) (list x2 y2))
    draw-line x1 y1 x2 y2 path-choice
  ][
   create-path
  ]
  draw-line x1 y1 x2 y2 path-choice
end

to draw-line [x1 y1 x2 y2 path-choice]
  let deltaX abs (x2 - x1)
  let deltaY abs (y2 - y1)
  let stepX ifelse-value (x1 < x2) [1] [-1]
  let stepY ifelse-value (y1 < y2) [1] [-1]
  let err (deltaX - deltaY)

  ; Tracer la ligne
  while [x1 != x2 or y1 != y2] [
    ; Vérifier si les coordonnées sont valides avant d'agir sur le patch
    if (x1 >= min-pxcor and x1 <= max-pxcor and y1 >= min-pycor and y1 <= max-pycor) [
      ask patch x1 y1 [ set pcolor brown ]


      if path-choice = 1 [
        if y1 + 1 <= max-pycor [
          ask patch x1 (y1 + 1) [ set pcolor brown ]  ; Patch à droite
        ]
        if y1 - 1 >= min-pycor [
          ask patch x1 (y1 - 1) [ set pcolor brown ]  ; Patch à gauche
        ]
      ]

      if path-choice = 2 [
        if x1 - 1 >= min-pxcor [
          ask patch (x1 - 1) y1 [ set pcolor brown ] ; Patch en bas
        ]
        if x1 + 1 <= max-pxcor [
          ask patch (x1 + 1) y1 [ set pcolor brown ] ; Patch en haut
        ]
      ]
    ]

    let error2 (err * 2)

    if error2 > (- deltaY) [
      set err (err - deltaY)
      set x1 x1 + stepX
    ]

    if error2 < deltaX [
      set err (err + deltaX)
      set y1 y1 + stepY
    ]
  ]

  ; Vérifier et colorier le dernier patch uniquement si valide
  if (x2 >= min-pxcor and x2 <= max-pxcor and y2 >= min-pycor and y2 <= max-pycor) [
    ask patch x2 y2 [ set pcolor brown ]



    if path-choice = 1 [
      if y2 + 1 <= max-pycor [
        ask patch x2 (y2 + 1) [ set pcolor brown ]
      ]
      if y2 - 1 >= min-pycor [
        ask patch x2 (y2 - 1) [ set pcolor brown ]
      ]
    ]

    if path-choice = 2 [
      if x2 - 1 >= min-pxcor [
        ask patch (x2 - 1) y2 [ set pcolor brown ]
      ]
      if x2 + 1 <= max-pxcor [
        ask patch (x2 + 1) y2 [ set pcolor brown ]
      ]
    ]
  ]
end

to draw-hunting-zone
  let margin 1 ; Taille du décalage pour réduire le cadre
  let min-width 40
  let min-height 40
  let hunting-zone-valid? false ; Indicateur de validité de la zone

  ; Générer une zone valide qui respecte les contraintes de visibilité et de superficie minimale
  while [not hunting-zone-valid?] [
    ; Générer des coordonnées aléatoires pour les coins de la zone de chasse (en entiers)
    let x1 round (random (max-pxcor - margin - min-pxcor - margin)) + min-pxcor + margin
    let y1 round (random (max-pycor - margin - min-pycor - margin)) + min-pycor + margin
    let x2 round (random (max-pxcor - margin - min-pxcor - margin)) + min-pxcor + margin
    let y2 round (random (max-pycor - margin - min-pycor - margin)) + min-pycor + margin

    ; S'assurer que (x1, y1) est en haut à gauche et (x2, y2) en bas à droite
    let x-left min list x1 x2
    let x-right max list x1 x2
    let y-bottom min list y1 y2
    let y-top max list y1 y2

    ; Calculer la largeur et la hauteur de la zone
    let width x-right - x-left
    let height y-top - y-bottom

    ; Vérifier si la superficie respecte la contrainte
    if (width >= min-width and height >= min-height) [
      ; Mettre à jour les coordonnées globales et marquer comme valide
      set hunting-zone-x1 x-left
      set hunting-zone-y1 y-top
      set hunting-zone-x2 x-right
      set hunting-zone-y2 y-bottom
      set hunting-zone-valid? true
    ]
  ]

  ; Tracer les bords de la zone en rouge
  ask patches [
    if (pxcor = hunting-zone-x1 and pycor >= hunting-zone-y2 and pycor <= hunting-zone-y1) or ; Bord gauche
       (pxcor = hunting-zone-x2 and pycor >= hunting-zone-y2 and pycor <= hunting-zone-y1) or ; Bord droit
       (pycor = hunting-zone-y2 and pxcor >= hunting-zone-x1 and pxcor <= hunting-zone-x2) or ; Bord bas
       (pycor = hunting-zone-y1 and pxcor >= hunting-zone-x1 and pxcor <= hunting-zone-x2)    ; Bord haut
    [
      set pcolor red ; Définir la couleur des bords

    ]
  ]

 ; je voudrais que si les lignes rouges coupent le chemin marron alors il y a des shapes qui apparaissent à leurs croisement
  add-stop-signs-at-crossings
end

to add-stop-signs-at-crossings
  ; Identifier les patches correspondant aux bords rouges de la zone de chasse
  ask patches with [pcolor = red] [
    ; Vérifier si ce patch rouge est aussi sur le chemin marron
    if pcolor = red and any? neighbors4 with [pcolor = brown] [
      ; Créer une tortue "panneau stop" à cet emplacement
      sprout 1 [
        set shape "tree" ; Assurez-vous que la forme "stop-sign" est définie dans l'interface
        set size 5 ; Ajuster la taille du panneau si nécessaire
        set color yellow ; Définir la couleur du panneau
      ]
    ]
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
355
10
-1
-1
1
14
1
1
1
0
0
0
1
1
1
1
ticks
30.0

SLIDER
5
60
182
93
initial-number-sheep
initial-number-sheep
0
1
1
NIL
HORIZONTAL

SLIDER
5
231
179
264
sheep-reproduce
sheep-reproduce
1.0
20.0
20.0
1.0
1
%
HORIZONTAL

BUTTON
40
140
109
173
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
115
140
190
173
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
10
360
350
530
populations
time
pop.
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"sheep" 1.0 0 -612749 true "" "plot count sheep"
"promeneurs" 1.0 0 -2674135 true "" "plot count promeneurs"

MONITOR
41
308
111
353
sheep
count sheep
3
1
11

TEXTBOX
10
210
150
228
Sheep settings
11
0.0
0

SWITCH
205
265
322
298
show-energy
show-energy
1
1
-1000

SLIDER
0
15
217
48
initial-number-promeneurs
initial-number-promeneurs
0
100
16.0
1
1
NIL
HORIZONTAL

MONITOR
135
305
212
350
promeneurs
count promeneurs
17
1
11

SLIDER
5
95
177
128
initial-number-wolf
initial-number-wolf
0
100
1
1
NIL
HORIZONTAL

@#$#@#$#@
## Qu'est ce que c'est 

Ce modèle est une simulation d'une partie de chasse.
Cette simulation se base sur un modèle proie-prédateurs. Notre modèle explore donc les différents scénarios d'une chasse en France de nos jours. 

Pour cela, nous avons défini et implémenté des règles de chasse actuelles qui sont censé permettre de réduire le nombre d'accidents liés à cette pratique. 

Les différentes règles que nous avons implémenté sont :
- Le fait de casser le fusil quand on ne met pas en joue un animal. 
- Le fait d'avoir de la signalisation à l'entrée des zones de chasse qui croise un sentier.
- Les promeneurs font donc demi tour quand ils voient le panneau zone de chasse.
- Les chasseurs restent dans la zone de chasse. 
- Les chasseurs se déplacent en formation.
- Les chasseurs ne tirent pas en direction de promeneurs ni de chasseurs.



## Comment cela fonctionne 

Il y a deux principales utilisations à ce modèle. 

Le premier avec la zone de chasse permet de définir une zone dans laquelle les chasseurs doivent resté mais pas les proies et donc une zone restrainte seulement pour les prédateurs.En plus de cela et de facon aléatoire un chemin pédestre peut la traverser pour simuler le comportement des chasseurs dans la cas, certes rare, où des promeneurs l'emprunteraient dans la cas ou ils n'auraient pas vu ou pas tenu compte des panneaux normalement censé se situer à l'entrée d'une zone de chasse qui coupent un sentier. 

Le second sans la zone de chasse permet de zoomer sur une zone de chasse plus grande où dans ce cas précis les animaux ne pourraient pas non plus s'échapper. Cela peut être le cas dans des zones grillagées près de grands axes comme des autoroutes ou nationales à 110km/h.
Dans ce cas, les prédateurs et les proies restent dans la même zone et seul le temps permet de finir la partie de chasse.
Des promeneurs sont aussi présent dans la zone de chasse 

## Comment l'utiliser

1. Définir le type de modèle (avec ou sans la zone de chasse)
2. Ajuster les paramètres pour faire correspondre à la simulation
3. appuyer sur SETUP.
4. Appuyer sur GO et regarder la simulation.
5. regarder les différentes courbes au cours du temps. 

Paramètres:

## ajouter les paramètres


Notes:
- one unit of energy is deducted for every step a wolf takes
- when running the sheep-wolves-grass model version, one unit of energy is deducted for every step a sheep takes

There are three monitors to show the populations of the wolves, sheep and grass and a populations plot to display the population values over time.

If there are no wolves left and too many sheep, the model run stops.


## THINGS TO TRY

Try adjusting the parameters under various settings. How sensitive is the stability of the model to the particular parameters?

Can you find any parameters that generate a stable ecosystem in the sheep-wolves model variation?

Try running the sheep-wolves-grass model variation, but setting INITIAL-NUMBER-WOLVES to 0. This gives a stable ecosystem with only sheep and grass. Why might this be stable while the variation with only sheep and wolves is not?

Notice that under stable settings, the populations tend to fluctuate at a predictable pace. Can you find any parameters that will speed this up or slow it down?

## EXTENDING THE MODEL

There are a number of ways to alter the model so that it will be stable with only wolves and sheep (no grass). Some will require new elements to be coded in or existing behaviors to be changed. Can you develop such a version?

Try changing the reproduction rules -- for example, what would happen if reproduction depended on energy rather than being determined by a fixed probability?

Can you modify the model so the sheep will flock?

Can you modify the model so that wolves actively chase sheep?

## NETLOGO FEATURES

Note the use of breeds to model two different kinds of "turtles": wolves and sheep. Note the use of patches to model grass.

Note the use of the ONE-OF agentset reporter to select a random sheep to be eaten by a wolf.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
set model-version "sheep-wolves-grass"
set show-energy? false
setup
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="New BehaviorSpace Features" repetitions="3" runMetricsEveryStep="false">
    <preExperiment>reset-timer</preExperiment>
    <setup>setup</setup>
    <go>go</go>
    <postExperiment>show timer</postExperiment>
    <timeLimit steps="200"/>
    <metric>count sheep</metric>
    <metric>count wolves</metric>
    <metric>[ xcor ] of sheep</metric>
    <metric>[ ycor ] of sheep</metric>
    <metric>[ xcor ] of wolves</metric>
    <metric>[ ycor ] of wolves</metric>
    <runMetricsCondition>ticks mod 2 = 0</runMetricsCondition>
    <subExperiment>
      <steppedValueSet variable="wolf-gain-from-food" first="30" step="5" last="50"/>
    </subExperiment>
  </experiment>
  <experiment name="BehaviorSpace run 3 experiments" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
print (word "sheep-reproduce: " sheep-reproduce ", wolf-reproduce: " wolf-reproduce)
print (word "sheep-gain-from-food: " sheep-gain-from-food ", wolf-gain-from-food: " wolf-gain-from-food)</setup>
    <go>go</go>
    <postRun>print (word "sheep: " count sheep ", wolves: " count wolves)
print ""
wait 1</postRun>
    <timeLimit steps="1500"/>
    <metric>count sheep</metric>
    <metric>count wolves</metric>
    <metric>count grass</metric>
    <runMetricsCondition>ticks mod 10 = 0</runMetricsCondition>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;sheep-wolves-grass&quot;"/>
    </enumeratedValueSet>
    <subExperiment>
      <enumeratedValueSet variable="sheep-reproduce">
        <value value="1"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="sheep-gain-from-food">
        <value value="1"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="wolf-reproduce">
        <value value="2"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="wolf-gain-from-food">
        <value value="10"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="sheep-reproduce">
        <value value="6"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="sheep-gain-from-food">
        <value value="8"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="wolf-reproduce">
        <value value="5"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="wolf-gain-from-food">
        <value value="20"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="sheep-reproduce">
        <value value="20"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="sheep-gain-from-food">
        <value value="15"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="wolf-reproduce">
        <value value="15"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="wolf-gain-from-food">
        <value value="30"/>
      </enumeratedValueSet>
    </subExperiment>
  </experiment>
  <experiment name="BehaviorSpace run 3 variable values per experiments" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
print (word "sheep-reproduce: " sheep-reproduce ", wolf-reproduce: " wolf-reproduce)
print (word "sheep-gain-from-food: " sheep-gain-from-food ", wolf-gain-from-food: " wolf-gain-from-food)</setup>
    <go>go</go>
    <postRun>print (word "sheep: " count sheep ", wolves: " count wolves)
print ""
wait 1</postRun>
    <timeLimit steps="1500"/>
    <metric>count sheep</metric>
    <metric>count wolves</metric>
    <metric>count grass</metric>
    <runMetricsCondition>ticks mod 10 = 0</runMetricsCondition>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;sheep-wolves-grass&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sheep-reproduce">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wolf-reproduce">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sheep-gain-from-food">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wolf-gain-from-food">
      <value value="20"/>
    </enumeratedValueSet>
    <subExperiment>
      <enumeratedValueSet variable="sheep-reproduce">
        <value value="1"/>
        <value value="6"/>
        <value value="20"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="wolf-reproduce">
        <value value="2"/>
        <value value="7"/>
        <value value="15"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="sheep-gain-from-food">
        <value value="1"/>
        <value value="8"/>
        <value value="15"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="wolf-gain-from-food">
        <value value="10"/>
        <value value="20"/>
        <value value="30"/>
      </enumeratedValueSet>
    </subExperiment>
  </experiment>
  <experiment name="BehaviorSpace subset" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <postRun>wait .5</postRun>
    <timeLimit steps="1500"/>
    <metric>count sheep</metric>
    <metric>count wolves</metric>
    <metric>count grass</metric>
    <runMetricsCondition>ticks mod 10 = 0</runMetricsCondition>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;sheep-wolves-grass&quot;"/>
    </enumeratedValueSet>
    <subExperiment>
      <enumeratedValueSet variable="wolf-reproduce">
        <value value="3"/>
        <value value="5"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="wolf-gain-from-food">
        <value value="30"/>
        <value value="40"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="wolf-reproduce">
        <value value="10"/>
        <value value="15"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="wolf-gain-from-food">
        <value value="10"/>
        <value value="15"/>
      </enumeratedValueSet>
    </subExperiment>
  </experiment>
  <experiment name="BehaviorSpace combinatorial" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <postRun>wait .5</postRun>
    <timeLimit steps="1500"/>
    <metric>count sheep</metric>
    <metric>count wolves</metric>
    <metric>count grass</metric>
    <runMetricsCondition>ticks mod 10 = 0</runMetricsCondition>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;sheep-wolves-grass&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wolf-reproduce">
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wolf-gain-from-food">
      <value value="10"/>
      <value value="15"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Wolf Sheep Crossing" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1500"/>
    <metric>count sheep</metric>
    <metric>count wolves</metric>
    <runMetricsCondition>count sheep = count wolves</runMetricsCondition>
    <enumeratedValueSet variable="wolf-gain-from-food">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wolf-reproduce">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-wolves">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-sheep">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;sheep-wolves-grass&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sheep-gain-from-food">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grass-regrowth-time">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sheep-reproduce">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="New BehaviorSpace Features reproducible" repetitions="3" runMetricsEveryStep="false">
    <preExperiment>reset-timer</preExperiment>
    <setup>random-seed (474 + behaviorspace-run-number)

setup</setup>
    <go>go</go>
    <postExperiment>show timer</postExperiment>
    <timeLimit steps="200"/>
    <metric>count sheep</metric>
    <metric>count wolves</metric>
    <metric>[ xcor ] of sheep</metric>
    <metric>[ ycor ] of sheep</metric>
    <metric>[ xcor ] of wolves</metric>
    <metric>[ ycor ] of wolves</metric>
    <runMetricsCondition>ticks mod 2 = 0</runMetricsCondition>
    <enumeratedValueSet variable="model-version">
      <value value="&quot;sheep-wolves-grass&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wolf-gain-from-food">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wolf-reproduce">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-wolves">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-sheep">
      <value value="100"/>
    </enumeratedValueSet>
    <subExperiment>
      <enumeratedValueSet variable="wolf-gain-from-food">
        <value value="10"/>
        <value value="20"/>
        <value value="30"/>
      </enumeratedValueSet>
    </subExperiment>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
