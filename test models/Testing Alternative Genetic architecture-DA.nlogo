extensions [matrix]
globals [WM WMT
 weight1 weight2 weight3 weight4 weight5 weight6 weight7 weight8 weight9 weight10 weight11 weight12 weight13 weight14 weight15 weight16 weight17 weight18 weight19 weight20 weight21
]
turtles-own
[
  sex mates mother father
  ;; matrix architecture
  GM G
  ;; explicit architecture
  gene1 gene2 gene3 gene4 gene5 gene6 gene7 gene8 gene9 gene10 gene11
  gene12 gene13 gene14 gene15 gene16 gene17 gene18 gene19 gene20 gene21
  locus1.1 locus1.2 locus2.1 locus2.2 locus3.1 locus3.2 locus4.1 locus4.2 locus5.1 locus5.2 locus6.1 locus6.2 locus7.1 locus7.2 locus8.1 locus8.2
  locus9.1 locus9.2 locus10.1 locus10.2 locus11.1 locus11.2 locus12.1 locus12.2 locus13.1 locus13.2 locus14.1 locus14.2 locus15.1 locus15.2 locus16.1
  locus16.2 locus17.1 locus17.2 locus18.1 locus18.2 locus19.1 locus19.2 locus20.1 locus20.2 locus21.1 locus21.2
  G2
  sum-locus-list
  ;; matrix architecture estimated from explicit architecture
  GMX G3
]

;;;;;;;;;;;;;;;;;;;;;;;;;; SET-UP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
 clear-all
 crt 100

 set WM matrix:from-row-list [[
  0.83734004
  0.70113835
  0.58709121
  0.49159498
  0.41163216
  0.34467609
  0.28861109
  0.24166563
  0.20235630
  0.16944104
  0.14187977
  0.11880161
  0.09947734
  0.08329636
  0.06974738
  0.05840227
  0.04890256
  0.04094807
  0.03428746
  0.02871027
      0
  ]]

  set weight1 0.83734004 set weight2 0.70113835 set weight3 0.58709121 set weight4 0.49159498 set weight5 0.41163216 set weight6 0.34467609
  set weight7 0.28861109 set weight8 0.24166563 set weight9 0.20235630 set weight10 0.16944104 set weight11 0.14187977 set weight12 0.11880161
  set weight13 0.09947734 set weight14 0.08329636 set weight15 0.06974738 set weight16 0.05840227 set weight17 0.04890256 set weight18 0.04094807
  set weight19 0.03428746 set weight20 0.02871027 set weight21 0

  ask turtles
  [
    ifelse random 2 = 1 [ set sex "female" set color grey ] [ set sex "male" set color red]
    setxy random-xcor random-ycor set mates (turtle-set)

    set-locus
    set-G2-from-explicit

    set GM matrix:from-row-list n-values 21 [n-values 2 [i -> random 2]]
    set-GM-from-explicit
    set-migratory-behaviour
  ]

  if (file-exists? "Testing-genetic-arch-Setup.csv")[carefully [ file-delete "Testing-genetic-arch-Setup.csv" ] [ print error-message ]]
  file-open "Testing-genetic-arch-Setup.csv"
     file-type "who,"
     file-type "Gmatrix,"
     file-type "Gexplicitarch,"
     file-type "Gmatrix_explicitarch,"
     file-print "Difference"
  file-close

  file-open "Testing-genetic-arch-Setup.csv"
  ask turtles
  [
    file-type (word who ",")
    file-type  (word G ",")
    file-type (word G2 ",")
    file-type (word G3 ",")
    file-print G - G2
  ]
  file-close

  if (file-exists? "Testing-genetic-arch-Runs.csv")[carefully [ file-delete "Testing-genetic-arch-Runs.csv" ] [ print error-message ]]
  file-open "Testing-genetic-arch-Runs.csv"
     file-type "who,"
     file-type "Gmatrix,"
     file-type "Gexplicitarch,"
     file-type "Gmatrix_explicitarch,"
     file-print "Difference"
  file-close

  reset-ticks
end

to set-GM-from-explicit
  set sum-locus-list (list (locus1.1 + locus1.2) (locus2.1 + locus2.2) (locus3.1 + locus3.2) (locus4.1 + locus4.2) (locus5.1 + locus5.2) (locus6.1 + locus6.2) (locus7.1 + locus7.2)
    (locus8.1 + locus8.2) (locus9.1 + locus9.2) (locus10.1 + locus10.2) (locus11.1 + locus11.2) (locus12.1 + locus12.2) (locus13.1 + locus13.2) (locus14.1 + locus14.2)
    (locus15.1 + locus15.2) (locus16.1 + locus16.2) (locus17.1 + locus17.2) (locus18.1 + locus18.2) (locus19.1 + locus19.2) (locus20.1 + locus20.2) (locus21.1 + locus21.2))
  set GMX matrix:from-row-list n-values 1 [n-values 21 [i -> item i sum-locus-list]]
end

;to-report fill-matrix [n m generator]
;  report matrix:from-row-list n-values n [n-values m [runresult generator]]
;end
;
;to-report get-initial-matrix-values
;  let value 1
;  let prob random-float 1
;  if prob < 0.25 [set value 0]
;  if prob > 0.75 [set value 2]
;  report value
;end

to set-G2-from-explicit
  set G2   (weight1 * locus1.1) + (weight1 * locus1.2) + (weight2 * locus2.1) + weight2 * (locus2.2) + (weight3 * locus3.1) + (weight3 * locus3.2) + (weight4 * locus4.1) + (weight4 * locus4.2)
    + (weight5 * locus5.1) + (weight5 * locus5.2) + (weight6 * locus6.1) + (weight6 * locus6.2) + (weight7 * locus7.1) + (weight7 * locus7.2) + (weight8 * locus8.1) + (weight8 * locus8.2)
    + (weight9 * locus9.1) + (weight9 * locus9.2) + (weight10 * locus10.1) + (weight10 * locus10.2) + (weight11 * locus11.1) + (weight11 * locus11.2) + (weight12 * locus12.1) + (weight12 * locus12.2)
    + (weight13 * locus13.1) + (weight13 * locus13.2) + (weight14 * locus14.1) + (weight14 * locus14.2) + (weight15 * locus15.1) + (weight15 * locus15.2) + (weight16 * locus16.1) + (weight16 * locus16.2)
    + (weight17 * locus17.1) + (weight17 * locus17.2) + (weight18 * locus18.1) + (weight18 * locus18.2) + (weight19 * locus19.1) + (weight19 * locus19.2) + (weight20 * locus20.1) + (weight20 * locus20.2)
end


to set-migratory-behaviour
  set WMT matrix:transpose WM
  let col1 matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column GM 0]]
  let col2 matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column GM 1]]
  let sum-G-matrix col1 matrix:+ col2
  let GM_WMT  matrix:times sum-G-matrix WMT
  set G matrix:get GM_WMT 0 0

  let GM_WMTX  matrix:times GMX WMT
  set G3 matrix:get GM_WMTX 0 0
end

;to-report matrix-power [ mat n ]
;  repeat n - 1 [
;    set mat matrix:times-element-wise GM 1
;  ]
;  report mat
;end

to set-locus
    set locus1.1 random 2 set locus1.2 random 2
    set gene1 list locus1.1 locus1.2
    set locus2.1 random 2 set locus2.2 random 2
    set gene2 list locus2.1 locus2.2
    set locus3.1 random 2 set locus3.2 random 2
    set gene3 list locus3.1 locus3.2
    set locus4.1 random 2 set locus4.2 random 2
    set gene4 list locus4.1 locus4.2
    set locus5.1 random 2 set locus5.2 random 2
    set gene5 list locus5.1 locus5.2
    set locus6.1 random 2 set locus6.2 random 2
    set gene6 list locus6.1 locus6.2
    set locus7.1 random 2 set locus7.2 random 2
    set gene7 list locus7.1 locus7.2
    set locus8.1 random 2 set locus8.2 random 2
    set gene8 list locus8.1 locus8.2
    set locus9.1 random 2 set locus9.2 random 2
    set gene9 list locus9.1 locus9.2
    set locus10.1 random 2 set locus10.2 random 2
    set gene10 list locus10.1 locus10.2
    set locus11.1 random 2 set locus11.2 random 2
    set gene11 list locus11.1 locus11.2
    set locus12.1 random 2 set locus12.2 random 2
    set gene12 list locus12.1 locus12.2
    set locus13.1 random 2 set locus13.2 random 2
    set gene13 list locus13.1 locus13.2
    set locus14.1 random 2 set locus14.2 random 2
    set gene14 list locus14.1 locus14.2
    set locus15.1 random 2 set locus15.2 random 2
    set gene15 list locus15.1 locus15.2
    set locus16.1 random 2 set locus16.2 random 2
    set gene16 list locus16.1 locus16.2
    set locus17.1 random 2 set locus17.2 random 2
    set gene17 list locus17.1 locus17.2
    set locus18.1 random 2 set locus18.2 random 2
    set gene18 list locus18.1 locus18.2
    set locus19.1 random 2 set locus19.2 random 2
    set gene19 list locus19.1 locus19.2
    set locus20.1 random 2 set locus20.2 random 2
    set gene20 list locus20.1 locus20.2
    set locus21.1 0 set locus21.2 0 ; neutral marker gets a 0 at both loci
    set gene21 list locus21.1 locus21.2
end

;;;;;;;;;;;;;;;;;;;;; GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  tick
  if ticks = 75 [write-test-output stop]
  ask turtles [move-to one-of patches]
  ask turtles [set mates (turtle-set)]
  ask turtles with [sex = "female"] [choose-mates]
  ask turtles with [sex = "female"]  [reproduce]
  ask n-of (count turtles with [sex = "female"] * 0.6) turtles [die]
end

;;;;;;;;;;;;;;;;;;;;;; PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to choose-mates ; females choose up to 5 male mates from a pool in their radius
  let availa-males turtles with [sex = "male"] in-radius 5
  let max-mate-count min (list 5 count availa-males)
  let new-mates n-of max-mate-count availa-males
  set mates (turtle-set mates new-mates)
  ask new-mates [ set mates (turtle-set mates myself) ]
end

to reproduce ; females produce 5 offspring which inherit traits from their parents
             ; the father traits are chosen from one of the female's mates
  if count mates > 0
   [
        hatch 1
        [
          set mother myself
          set father one-of [mates] of mother

          create-genes-from-explicit
          set-G2-from-explicit
          set-GM-from-explicit

          let motherGM [GM] of mother
          let motherLocus matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column motherGM random 2]]
          let fatherGM [GM] of father
          let fatherLocus matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column fatherGM random 2]]
          set GM matrix:from-row-list n-values 21 [n-values 2 [i -> 0]]
          matrix:set-column GM 0 matrix:get-row motherLocus 0
          matrix:set-column GM 1 matrix:get-row fatherLocus 0

          ifelse random 2 = 1
           [ set color red set sex "male" ]
           [ set color grey set sex "female" ]

          set-migratory-behaviour
      ]
  ]
end

;to-report pre-val-change [ val ]
;  let new-val val
;  if val = 2 [set new-val val * 2]
;  report new-val
;end
;
;to-report val-change [ val ]
;  let new-val val
;  if val = 0.5 [set new-val random 2]
;  if val = 1
;    [
;      let prob random-float 1
;      ifelse  prob < 0.25
;      [set new-val 0]
;      [ifelse prob > 0.75
;        [set new-val 2]
;        [set new-val 1]]
;    ]
;  if val = 2 [set new-val 1]
;  if val = 2.5 [set new-val 1 + random 2]
;  if val = 4 [set new-val 2]
;  report new-val
;end

to create-genes-from-explicit
  set locus1.1 one-of [gene1] of mother
      set locus1.2 one-of [gene1] of father
      set gene1  list locus1.1 locus1.2
      set locus2.1 one-of [gene2] of mother
      set locus2.2 one-of [gene2] of father
      set gene2  list locus2.1 locus2.2
      set locus3.1 one-of [gene3] of mother
      set locus3.2 one-of [gene3] of father
      set gene3  list locus3.1 locus3.2
      set locus4.1 one-of [gene4] of mother
      set locus4.2 one-of [gene4] of father
      set gene4  list locus4.1 locus4.2
      set locus5.1 one-of [gene5] of mother
      set locus5.2 one-of [gene5] of father
      set gene5  list locus5.1 locus5.2
      set locus6.1 one-of [gene6] of mother
      set locus6.2 one-of [gene6] of father
      set gene6  list locus6.1 locus6.2
      set locus7.1 one-of [gene7] of mother
      set locus7.2 one-of [gene7] of father
      set gene7  list locus7.1 locus7.2
      set locus8.1 one-of [gene8] of mother
      set locus8.2 one-of [gene8] of father
      set gene8  list locus8.1 locus8.2
      set locus9.1 one-of [gene9] of mother
      set locus9.2 one-of [gene9] of father
      set gene9  list locus9.1 locus9.2
      set locus10.1 one-of [gene10] of mother
      set locus10.2 one-of [gene10] of father
      set gene10  list locus10.1 locus10.2
      set locus11.1 one-of [gene11] of mother
      set locus11.2 one-of [gene11] of father
      set gene11  list locus11.1 locus11.2
      set locus12.1 one-of [gene12] of mother
      set locus12.2 one-of [gene12] of father
      set gene12  list locus12.1 locus12.2
      set locus13.1 one-of [gene13] of mother
      set locus13.2 one-of [gene13] of father
      set gene13  list locus13.1 locus13.2
      set locus14.1 one-of [gene14] of mother
      set locus14.2 one-of [gene14] of father
      set gene14  list locus14.1 locus14.2
      set locus15.1 one-of [gene15] of mother
      set locus15.2 one-of [gene15] of father
      set gene15  list locus15.1 locus15.2
      set locus16.1 one-of [gene16] of mother
      set locus16.2 one-of [gene16] of father
      set gene16  list locus16.1 locus16.2
      set locus17.1 one-of [gene17] of mother
      set locus17.2 one-of [gene17] of father
      set gene17  list locus17.1 locus17.2
      set locus18.1 one-of [gene18] of mother
      set locus18.2 one-of [gene18] of father
      set gene18  list locus18.1 locus18.2
      set locus19.1 one-of [gene19] of mother
      set locus19.2 one-of [gene19] of father
      set gene19  list locus19.1 locus19.2
      set locus20.1 one-of [gene20] of mother
      set locus20.2 one-of [gene20] of father
      set gene20  list locus20.1 locus20.2
      set locus21.1 one-of [gene21] of mother
      set locus21.2 one-of [gene21] of father
      set gene21  list locus21.1 locus21.2
end

to write-test-output
  file-open "Testing-genetic-arch-Runs.csv"
  ask turtles
  [
    file-type (word who ",")
    file-type  (word G ",")
    file-type (word G2 ",")
    file-type (word G3 ",")
    file-print G - G2
  ]
  file-close
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
61
24
124
57
NIL
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

PLOT
1034
15
1234
165
G male
NIL
NIL
0.0
20.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [G] of turtles with [sex = \"male\"]"

MONITOR
669
19
752
64
mean G male
mean [g] of turtles with [sex = \"male\"]
3
1
11

PLOT
1038
187
1238
337
G female
NIL
NIL
0.0
20.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [G] of turtles with [sex = \"female\"]"

MONITOR
833
17
949
62
mean G of females
mean [G] of turtles with [sex = \"female\"]
3
1
11

MONITOR
669
69
770
114
variance G male
variance [G] of turtles with [sex = \"male\"]
3
1
11

MONITOR
832
66
944
111
variance G female
variance [G] of turtles with [sex = \"female\"]
3
1
11

MONITOR
668
146
758
191
mean G2 male
mean [G2] of turtles with [sex = \"male\"]
3
1
11

MONITOR
832
143
941
188
mean G2 females
mean [G2] of turtles with [sex = \"female\"]
3
1
11

MONITOR
667
205
775
250
variance G2 males
variance [G2] of turtles with [sex = \"male\"]
3
1
11

MONITOR
830
205
955
250
variance G2 females
variance [G2] of turtles with [sex = \"female\"]
3
1
11

BUTTON
61
68
124
101
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
670
283
766
328
mean G3 males
mean [G3] of turtles with [sex = \"male\"]
3
1
11

MONITOR
669
339
782
384
variance G3 males
variance [G3] of turtles with [sex = \"male\"]
3
1
11

MONITOR
832
283
940
328
mean G3 females
mean [G3] of turtles with [sex = \"female\"]
3
1
11

MONITOR
831
340
956
385
variance G3 females
variance [G3] of turtles with [sex = \"female\"]
3
1
11

MONITOR
668
399
725
444
N trout
count turtles
0
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
0
@#$#@#$#@
