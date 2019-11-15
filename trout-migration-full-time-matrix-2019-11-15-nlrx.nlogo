; Trout Migration and Parasitism Model

; https://homepage.stat.uiowa.edu/~mbognar/applets/bin.html
;extensions [rnd time matrix profiler]
extensions [rnd matrix profiler]
globals
[
  day
  year
  start-time
  current-time
  my-month
  my-week
;  my-day

  WM ; weight matrix for females
  WMc ; weight matrix for males
  Gpm ; mean genotypic value of the male population
  Gpf ; mean genotypic value of the male population

  Ve
  Va
  Vp
  mu_cond
  V_cond

  a
  b
  SurvRate
 ; L
 ; k
 ; mass0

;GM_WMT ;; ADAM CHANGES 15/07/2019
  ; Global parameters used to find a structured population
  anad-tactic-ratio-list
  stop?

] ;; added start-time and current-time


turtles-own
[
  mates
  sea-time
  state
  habitat

;  WMT ;;not needed anymore
  GM
  GM_val

  G
;  Vp
;  Va

  cond
  e_thresh
  z_thresh
  anadromous

  mother
  father

  quality
  age
  sex

  motherID
  fatherID

; males
  start_quality

; females
  mate-count
  G-standardised
  ;time-since-repro
  FecAcc ; accumulated fecundity (number of offspring produced so far)
]

patches-own [parasites?]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP PROCEDURE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  reset-ticks
  set-environment
  set-parameters
  set-population
;  set-outputs
;  reset-ticks
end

to set-environment
  ; time schedule
  ; here we specify the start date of the model
;  set start-time time:create "2000-12-01"
 ; set current-time time:anchor-to-ticks start-time 1.0 "days"
 ; time:anchor-schedule start-time 1.0 "days"
;  set current-time time:anchor-to-ticks start-time 1.0 "weeks"
;  time:anchor-schedule start-time 1.0 "weeks"
  set year 0
  set my-week 48
  set my-month 12

  ; create freshwater habitat - cyan coloured patches - and marine habitat - blue coloured patches
  ask patches [set pcolor cyan]
  ask patches with [pxcor >= 50] [set pcolor blue]

  ; set the proportion of marine patches that have parasites
  ; this is controlled by a slider on the gui called prop-parasites
  let percentage prop-parasites
  let sea patches with [pcolor = blue]
  ask  n-of (percentage * count sea) sea
   [set parasites? "yes"]
end


; here we have two weights matrices, one for males and one for females
; we want to control the expected additive genetic value for the threshold trait
; and to weight the contribution of each locus according to a negative exponential function
; the males multiply their values by -1 for a user-defined number of weights set using n-loci-sign
; on the gui



to set-parameters

;set WM matrix:from-row-list
set WM matrix:from-column-list
  [
    [
      0.9280339
      0.8612468
      0.7992662
      0.7417461
      0.6883655
      0.6388265
      0.5928526
      0.5501873
      0.5105924
      0.4738471
      0.4397461
      0.4080993
      0.3787300
      0.3514742
      0.3261800
      0.3027061
      0.2809215
      0.2607046
      0.2419427
      0.2245310
      0
    ]
  ]

;set WMc matrix-row-manipulation WM 0 0 n-loci-sign -1
set WMc matrix:transpose (matrix-row-manipulation matrix:transpose WM 0 0 n-loci-sign -1)

set Gpm reduce + matrix:get-column WMc 0
set Gpf reduce + matrix:get-column WM 0

; set Va 2.94706
set Ve 2.94706
; set Vp 5.89412

set mu_cond  10       ; mean value of the condition trait
set V_cond  2.94706   ; variance of the condition trait (in this case, all the phenotypic variance is environmental)

; these values determine the fecundity of the female fish as a function of her quality - they feed into an allometric equation
; http://www.freshwaterlife.org/projects/media/projects/images/1/50094_ca_object_representations_media_163_original.pdf
  ; N = a*L^b, where L is length in mm so we'd expect a 200mm fish to produce 0.000238781 * 200 ^ 2.603 =
set a  0.0000866 ; log10(a) = -4.0623
set b  2.7514
set SurvRate 0.1
;set mass0  150

end

to set-population
  ; create the population of trout in the freshwater habitat
  create-turtles n-trout
  [
    ifelse random 2 = 1
      [set sex "male" set color red]
      [set sex "female" set color grey]

    move-to one-of patches with [pcolor = cyan]
    set habitat "fresh" ; all fish start off in freshwater
    set state "healthy" ; all fish start off without parasites
    set mates (turtle-set)
    set size 2         ; represents size of the fish on screen, purely aesthetic
    set sea-time 0
    set FecAcc 0
   ; set time-since-repro 52 ; females have to start with this otherwise they never reproduce
    set GM matrix:from-row-list n-values 21 [n-values 2 [i -> random 2]]
    set-migratory-behaviour
  ]

  set anad-tactic-ratio-list (list (count turtles with [anadromous = False] / count turtles))
  set stop? FALSE
end

; this function is used to set out how the matrices are populated
  to-report fill-matrix [n m generator]
  report matrix:from-row-list n-values n [n-values m [runresult generator]]
  end

; this function sets the signs of the weight matrix and allows for differences between the sexes
; in terms of genetic correlations to be created
to-report matrix-row-manipulation [matrix row columen-index-start columen-index-end multiplier]
  let index (range columen-index-start columen-index-end 1)
  foreach index [ i ->
    set matrix matrix:set-and-report matrix row i (matrix:get matrix row i * multiplier )
  ]
  report matrix
end


; the weights matrix differs for females and males here
; this builds up a gene matrix of 1s and 0s and weights them by the weights matrix
; the sum of this matrix G is the genetic value for the threshold trait
; this value is used along with the environmental value for each fish to determine which
; migratory tactic an individual assumes by adding it to the genetic value to get
; a phenotypic value z_thresh. If the condition, an entirely environmentally derived value,
; exceeds your threshold the fish becomes a resident otherwise it becomes anadromous

to set-migratory-behaviour

;  ifelse sex = "female" [set WMT matrix:transpose WM] [set WMT matrix:transpose WMc]
  let col1 matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column GM 0]]
  let col2 matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column GM 1]]
  let sum-G-matrix col1 matrix:+ col2
;  let GM_WMT  matrix:times sum-G-matrix WMT

  let GM_WMT  matrix:times sum-G-matrix WM ; ADAM CHANGE 15/07/2015
  ifelse sex = "female" [set GM_WMT  matrix:times sum-G-matrix WM] [set GM_WMT  matrix:times sum-G-matrix WMc] ; ADAM CHANGE 15/07/2019

  ifelse evolution?
  [set G matrix:get GM_WMT 0 0][ifelse sex = "female" [set G Gpf] [set G Gpm]]

   set e_thresh random-normal 0 (sqrt(Ve))
   set z_thresh G + e_thresh
   set cond random-normal mu_cond  sqrt(V_cond)
   ifelse(cond > z_thresh)
    [set anadromous false ] ;set quality random-normal res_quality_mean res_quality_sd] ; 100 10
    [set anadromous true  ] ; set quality random-normal anad_quality_mean anad_quality_sd] ; 200 10
   set quality random-normal res_quality_mean res_quality_sd
   if sex = "male" and anadromous =  false [set start_quality quality]

   let preGM_val matrix:pretty-print-text GM
   set GM_val read-from-string preGM_val
end


to set-outputs
  if (file-exists? "anadromous-ratio.csv") [carefully [file-delete "anadromous-ratio.csv"] [print error-message]]
  file-open "anadromous-ratio.csv"
  file-type "year,"
  file-type "anad-tactic-ratio,"
  file-type  "anad-tactic-ratio-males,"
  file-type  "anad-tactic-ratio-females,"
  file-print "anad-tactic-ratio-spawners"
  file-close
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SCHEDULING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  tick ; iterate the model

;0. Update time counters:
;  if ticks mod 364 = 0 [set year year + 1] ; iterate the year
  if ticks mod 52 = 0 [set year year + 1] ; iterate the year
 ; if year = 300 [stop] ; tell the model to stop at final simulation time
  if my-week = 48 and Check-Stability? [check-stability]
  if stop? = TRUE and Check-Stability? [export-world "stable-population.csv" stop]
  set my-week my-week + 1 if my-week > 52 [set my-week 1]
  set my-month (int(my-week / 4.5) mod 52) + 1
;  set my-month  time:get "month" current-time ; extract the month so fish can keep track of their schedule
;  set my-week  time:get "week" current-time ; extract the week so fish can keep track of their schedule
;  set my-day  time:get "day" current-time ; extract the day so fish can keep track of their schedule

;1. Update trout age and time counters
  ask turtles  ;; time counters are updated
   [
     set age (1 + age)  ; increment-age
     if habitat = "marine" [set sea-time sea-time + 1] ;; increment time at sea
   ]

;2. Mortality actions:
  ask turtles with [age = lifespan] [die] ;; mortality by senescence

  if count turtles with [habitat = "fresh"] > carryingCapacity [grim-reaper] ;; density-dependent mortality

  mortality ;; density-independent mortality

;3. Migrate:
  ask turtles with [anadromous = true and age > 104]  ;; trout migrate
   [
      if my-week = 14 and habitat = "fresh" [migrate-to-ocean]
;      if my-week = 43 and habitat = "marine" and sea-time > 80 [check-quality]
      if my-week = 44 and sea-time > 80 [migrate-to-freshwater]
  ]

;4. Reproduction actions:

  ; reproduction starts on 1st December
  ; only females who are adults, i.e. over a year old, are subject to the reproduction procedures
  ; of choosing mates and reproducing
  if my-week = 48 and year > 1
   [
    ask turtles with [habitat = "fresh"] [ move-to one-of patches with [pcolor = cyan]] ;; fish in the fresh water disperse before reproduction
    let spawners turtles with [age > 104 and habitat = "fresh"]
    let sneakers spawners with [sex = "male" and anadromous = false]
    ask sneakers [sneaker] ;; the sneaker tactic can be turned on or off on the gui; it only applies to adult resident males
    ask spawners [set mates ( turtle-set )]
    ask spawners with [sex = "female"]
     [
      choose-mates
      reproduce
     ]
    ask sneakers [set quality start_quality]
    genetic-coding-transmission
   ]

;5. Observer write outputs
;  if my-week = 47 [set anad-tactic-ratio-list fput (count turtles with [anadromous = true] / count turtles) anad-tactic-ratio-list]
;  if my-week = 47 [write-outputs]

end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBMODELS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; kill turtles in excess of carrying capacity
to grim-reaper
 let freshwaters turtles with [habitat = "fresh"]
 let max-age max [age] of freshwaters
 ask rnd:weighted-n-of (count freshwaters - carryingCapacity) freshwaters [max-age - age ] [ die ]

;  let num-turtles count turtles with [habitat = "fresh"]
;  let chance-to-die (num-turtles - carryingCapacity) / num-turtles
;  if random-float 1.0 < chance-to-die [ die ]
end


; Mortality procedure,
; The chance of dying varies for males, females, by habitat and depending on whether you are parasitiised

to mortality
  ask turtles with [sex = "male"]
   [
    let prob-deathM mortalityM
    ifelse habitat = "fresh"
     [
      if random-float 1 < prob-deathM [die] ; chance of dying on any turn in freshwater
     ]
     [
      ifelse state = "healthy"
        [ set prob-deathM mortalityM * anad-death-multiplierM] ; anad-death-multiplierM  ]                 ; higher likelihood of death while at sea
        [ set prob-deathM mortalityM * anad-death-multiplierM * parasite-load] ; anad-death-multiplierM * parasite-load ]  ; higher likelihood again of dying if parasitized while at sea
      if random-float 1 < prob-deathM [die] ; death procedure
     ]
   ]

  ask turtles with [sex = "female"]
    [
      let prob-deathF mortalityF
      ifelse habitat = "fresh"
      [
       if random-float 1 < prob-deathF [die] ] ; chance of dying on any turn in freshwater
      [
       ifelse state = "healthy"
        [ set prob-deathF mortalityF * anad-death-multiplierF] ; anad-death-multiplierF ]                  ; higher likelihood of death while at sea
        [ set prob-deathF mortalityF * anad-death-multiplierF * parasite-load] ; anad-death-multiplierF * parasite-load ]  ; higher likelihood again of dying if parasitized while at sea
       if random-float 1 < prob-deathF [die]
      ]
    ]
end

; resident males look around a radius of 5 patches and count the proportion of anadromous males
; relative to residents. If the proportion of anadromous males is greater than the sneaker_threshold
; the resident gets a boost to its quality, the sneaker_boost

to sneaker
  let availa-rivals turtles with [sex = "male" and age > 104] in-radius sneaker_radius
  let rivals availa-rivals with [anadromous = true]
  let prop_rivals count rivals / count availa-rivals
  ifelse prop_rivals > sneaker_thresh ; 0.8
   [set quality start_quality + sneaker_boost  ] ; 200
   [set quality start_quality]
end

; tells the fish when to migrate
; once at sea the fish do not move
; they may land on a patch with parasites which will affect their quality
; this in turn affects their fecundity, if female, or chance of mating, if male
; fish migrate to sea on 1st April and return to freshwater on 1st November

; Difference between Apr 1, 2019 and Nov 1, 2020:
; 1 years 7 months 0 days
; or 19 months 0 days
; or 82 weeks 6 days
; or 580 calendar days

to migrate-to-ocean
   move-to one-of patches with [pcolor = blue]
   set habitat "marine"
   if parasites? = "yes"
    [
     set state "parasitised"
  ;   set quality paras_quality;random-normal paras_quality_mean paras_quality_sd ; 150 10
    ]
end

to migrate-to-freshwater
  ;; fish update their quality after the time spent at sea, it depends on their state
  ;; parasitised fish become healthy again when they return to fresh water
  ;; this means their quality remains lower but they don't have the increased mortality cost once they return
  ;; repeated-spawners have a lower quality gain because they spend only one summer at sea before migrating back to fresh water
;  ifelse state = "parasitised" [ set quality quality + (anad_quality * (1 - paras_quality))] [set quality quality + anad_quality]
  let quality_gained anad_quality                                                     ;; quality gained by healthy first-time spawners
  if sea-time > 100 [set quality_gained anad_quality * (30 / 82)]                     ;; quality gained by healthy repeated-spawners
  if state = "parasitised" [set quality_gained quality_gained * (1 - paras_quality)]  ;; quality gained by parasitised spawners
  set quality quality + quality_gained
  move-to one-of patches with [pcolor = cyan]
  set habitat "fresh"
  set state "healthy"
;  set sea-time 0
end

;to check-quality
;  ifelse state = "parasitised" [ set quality quality - paras_quality] [set quality quality + anad_quality]
;end


; females choose up to 5 male mates from a pool of males in freshwater habitat over a certain age in their radius
; females choose the males based on the quality of the males
; this quality variable is set based on the migratory tactic and can vary if you are a sneaker or if you have been parasitised

to choose-mates
  let male-spawners turtles with [sex = "male" and habitat = "fresh" and age > 104]
  let availa-males male-spawners in-radius female-mate-radius
  let max-mate-count min (list 5 count availa-males)
  let new-mates rnd:weighted-n-of max-mate-count availa-males [ quality ]
  set mates (turtle-set mates new-mates)
  ask new-mates [ set mates (turtle-set mates myself) ]
end

; females produce offspring which inherit traits from their parents
; the father traits are chosen from one of the female's mates
; fecundity is a function of female quality which is a variable in a logistic function
; as for males, this quality variable is set based on the migratory tactic and can vary if you have been parasitised
; there is no sneaker tactic for females so this does not play a role in affecting female quality

to reproduce
  if count mates > 0
   [
      ; let fecundity   L / (1 + exp(- k * (quality - mass0)))
      let fecundity ( a * quality ^ b ) * SurvRate ; / 50
      if anadromous = false [set fecundity (fecundity * Fec-reduction-resid)]
      set FecAcc FecAcc + round fecundity ; added round here to keep the values as integers
      hatch round fecundity
      [
        set mother myself
        set motherID [who] of mother

        set father one-of [mates] of mother
        set fatherID [who] of father

;        let motherGM [GM] of mother
;        let motherLocus matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column motherGM random 2]]
;        let fatherGM [GM] of father
;        let fatherLocus matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column fatherGM random 2]]
;        set GM matrix:from-row-list n-values 21 [n-values 2 [i -> 0]]
;        matrix:set-column GM 0 matrix:get-row motherLocus 0
;        matrix:set-column GM 1 matrix:get-row fatherLocus 0

        set habitat "fresh"
        set state "healthy"
        set age 0
        set FecAcc 0
        set mates (turtle-set)
        ifelse random 2 = 1
         [
          set color red
          set sex "male"
         ]
         [
          set color grey
          set sex "female"
         ]

;        set-migratory-behaviour
      ]
  ]
end

; if the population is over K after emergence, the surplus of newborns die;
; surviving newborns inherit their genetic material from their parents;
; finally, they set theri migratory tacti

to genetic-coding-transmission
  let freshwaters turtles with [habitat = "fresh"]
  let newborns turtles with [age = 0]
  if count freshwaters > carryingCapacity
   [
    ask n-of (count freshwaters - carryingCapacity) newborns [ die ]
   ]
  ask newborns
   [
    let motherGM [GM] of mother
    let motherLocus matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column motherGM random 2]]
    let fatherGM [GM] of father
    let fatherLocus matrix:from-row-list n-values 1 [n-values 21 [i -> item i matrix:get-column fatherGM random 2]]
    set GM matrix:from-row-list n-values 21 [n-values 2 [i -> 0]]
    matrix:set-column GM 0 matrix:get-row motherLocus 0
    matrix:set-column GM 1 matrix:get-row fatherLocus 0

    set-migratory-behaviour
   ]
end

to write-outputs
  file-open "anadromous-ratio.csv"
  file-type (word year ",")
  ifelse count turtles > 0 [file-type (word (count turtles with [anadromous = true] / count turtles) ",")] [file-type "-"]
  ifelse count turtles with [sex = "male"] > 0 [file-type (word (count turtles with [sex = "male" and anadromous = true] / count turtles with [sex = "male"]) ",")] [file-type "-"]
  ifelse count turtles with [sex = "female"] > 0 [file-type (word (count turtles with [sex = "female" and anadromous = true] / count turtles with [sex = "female"]) ",")] [file-type "-"]
  ifelse count turtles with [FecAcc > 0] > 0 [file-print count turtles with [anadromous = True and FecAcc > 0] / count turtles with [FecAcc > 0]] [file-print "-"]
  file-close
end


to check-stability
  let year-anad-tactic-ratio count turtles with [anadromous = True] / count turtles  ; proportion of anadromous trout in the current year
  set anad-tactic-ratio-list fput year-anad-tactic-ratio anad-tactic-ratio-list
  let stability-period 100 ; number of simulated years over which stability conditions are checked
  if length anad-tactic-ratio-list > stability-period [set anad-tactic-ratio-list remove-item stability-period anad-tactic-ratio-list]
  let my-mean mean anad-tactic-ratio-list
  let my-cv standard-deviation anad-tactic-ratio-list / my-mean
  let my-cv-threshold 0.04 ; 10% forces the mean value to be within 0.475-0.525 over the evaluated period, 5% within 0.4875-0.5125, 4% within 0.49-0.51...
  if year > 100 and ; let run the simulation longer than the checked-stability period
     my-cv <= my-cv-threshold and ; stability condition (variability below a set threshold)
     my-mean >=  0.5 * (1 - (my-cv-threshold / 2)) and my-mean <=  0.5 * (1 + (my-cv-threshold / 2)) and ; mean as close to 0.5 as possible
     year-anad-tactic-ratio >= 0.495 and  year-anad-tactic-ratio <= 0.505 ; the value of the current year as close to 0.5 as possible
   [
     set stop? TRUE
   ]
end

to-report anadromous-spawners
  let anad_spawn 0
  ifelse count turtles with [FecAcc > 0] > 0
   [set anad_spawn count turtles with [anadromous = True and FecAcc > 0] / count turtles with [FecAcc > 0]]
   [set anad_spawn "-"]
  report anad_spawn
end
@#$#@#$#@
GRAPHICS-WINDOW
246
10
654
419
-1
-1
4.0
1
10
1
1
1
0
0
1
1
0
99
0
99
0
0
1
ticks
30.0

BUTTON
11
10
74
43
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

BUTTON
78
10
141
43
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
78
79
140
124
male trout
count turtles with [sex = \"male\"]
17
1
11

MONITOR
10
79
80
124
female trout
count turtles with [sex = \"female\"]
17
1
11

SLIDER
10
43
113
76
n-trout
n-trout
0
10000
3000.0
1
1
NIL
HORIZONTAL

TEXTBOX
92
126
134
144
red
11
0.0
1

TEXTBOX
20
125
65
143
grey
11
0.0
1

MONITOR
938
167
1062
212
anadromous males
count turtles with [sex = \"male\" and anadromous = true]
17
1
11

MONITOR
662
169
789
214
anadromous females
count turtles with [sex = \"female\" and anadromous = true]
17
1
11

MONITOR
1062
167
1188
212
resident males
count turtles with [sex = \"male\" and anadromous = false]
17
1
11

MONITOR
789
168
916
213
resident females
count turtles with [sex = \"female\" and anadromous = false]
17
1
11

MONITOR
140
79
206
124
total trout 
count turtles
17
1
11

SLIDER
9
208
129
241
mortalityM
mortalityM
0
1
0.01543
.00001
1
NIL
HORIZONTAL

INPUTBOX
9
246
140
306
anad-death-multiplierM
1.65
1
0
Number

MONITOR
104
150
161
195
NIL
year
17
1
11

SLIDER
10
325
131
358
mortalityF
mortalityF
0
1
0.01543
.00001
1
NIL
HORIZONTAL

INPUTBOX
6
382
138
442
anad-death-multiplierF
1.65
1
0
Number

SLIDER
7
514
179
547
female-mate-radius
female-mate-radius
0
100
6.0
1
1
NIL
HORIZONTAL

PLOT
665
221
937
425
Strategy proportions
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"anad males" 1.0 0 -1184463 true "" "plot count turtles with [sex = \"male\" and anadromous = true] / count turtles with [sex = \"male\"]\n"
"res males" 1.0 0 -13345367 true "" "plot count turtles with [sex = \"male\" and anadromous = false] / count turtles  with [sex = \"male\"]"
"anad fem" 1.0 0 -2674135 true "" "plot count turtles with [sex = \"female\" and anadromous = true] / count turtles  with [sex = \"female\"]\n"
"res fem" 1.0 0 -10899396 true "" "plot count turtles with [sex = \"female\" and anadromous = false] / count turtles  with [sex = \"female\"]"

SLIDER
7
462
179
495
carryingCapacity
carryingCapacity
0
100000
3000.0
1
1
NIL
HORIZONTAL

SLIDER
8
569
163
602
prop-parasites
prop-parasites
0.00
1
0.0
0.01
1
NIL
HORIZONTAL

PLOT
946
218
1146
368
Trout with parasites
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [state = \"parasitised\"]"

PLOT
662
10
862
160
G of females
NIL
NIL
0.0
20.0
0.0
20.0
true
false
"" ""
PENS
"default" 0.5 1 -16777216 true "" "histogram [G] of turtles with [sex = \"female\"]"

PLOT
937
10
1137
160
G of males 
NIL
NIL
0.0
20.0
0.0
20.0
true
false
"" ""
PENS
"default" 0.5 1 -16777216 true "" "histogram [G] of turtles with [sex = \"male\"] "

INPUTBOX
8
603
163
663
parasite-load
1.4
1
0
Number

MONITOR
870
13
930
58
mean
mean [G] of turtles with [sex = \"female\"]
4
1
11

MONITOR
870
56
930
101
variance
variance [G] of turtles with [sex = \"female\"]
5
1
11

MONITOR
872
103
929
148
SD
standard-deviation [G] of turtles with [sex = \"female\"]
5
1
11

MONITOR
1154
10
1215
55
mean
mean [G] of turtles with [sex = \"male\"]
4
1
11

MONITOR
1155
56
1215
101
variance
variance [G] of turtles with [sex = \"male\"]
5
1
11

MONITOR
1155
105
1214
150
SD
standard-deviation [G] of turtles with [sex = \"male\"]
5
1
11

PLOT
1148
218
1348
368
Fish at sea
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [pcolor = blue]"

MONITOR
1150
368
1223
413
Fish at sea
count turtles with [pcolor = blue]
17
1
11

MONITOR
947
368
1043
413
Parasitised fish
count turtles with [state = \"parasitised\"]
17
1
11

TEXTBOX
1680
10
1988
168
In males quality is a trait variable that is selected by the females. \n\nIt is drawn from a random-normal and does not evolve\n\nIn females it governs their fecundity\n
11
0.0
1

PLOT
1258
10
1458
160
Quality of  males
NIL
NIL
50.0
300.0
0.0
10.0
true
false
"" ""
PENS
"residents" 1.0 1 -2674135 true "" "histogram [quality] of turtles with [sex = \"male\"] \n"

TEXTBOX
142
209
233
238
background mortality of males
11
0.0
1

TEXTBOX
145
328
237
380
background mortality of females
11
0.0
1

TEXTBOX
11
672
161
700
extra mortality due to parasites
11
0.0
1

TEXTBOX
147
386
232
451
extra mortality due to marine environ for females
11
0.0
1

TEXTBOX
152
250
230
314
extra mortality due to marine environ for \nmales
11
0.0
1

PLOT
1463
10
1663
160
Quality of females
NIL
NIL
50.0
300.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -7500403 true "" "histogram [quality] of turtles with [sex = \"female\"] "

MONITOR
678
445
776
490
Prop anad male
count turtles with [sex = \"male\" and anadromous = true] / count turtles with [sex = \"male\"]
3
1
11

MONITOR
781
444
891
489
Prop anad female
count turtles with [sex = \"female\" and anadromous = true] / count turtles with [sex = \"female\"]
3
1
11

INPUTBOX
244
666
399
726
res_quality_mean
230.0
1
0
Number

INPUTBOX
398
666
553
726
res_quality_sd
10.0
1
0
Number

INPUTBOX
244
726
399
786
anad_quality
170.0
1
0
Number

INPUTBOX
398
726
553
786
anad_quality_sd
0.0
1
0
Number

INPUTBOX
244
785
399
845
paras_quality
0.4
1
0
Number

SWITCH
246
439
351
472
sneaker?
sneaker?
0
1
-1000

TEXTBOX
368
440
476
468
sneaker tactic by resident males
11
0.0
1

BUTTON
148
10
214
43
Profile
setup                  ;; set up the model\nprofiler:start         ;; start profiling\nrepeat 30 [ go ]       ;; run something you want to measure\nprofiler:stop          ;; stop profiling\nprint profiler:report  ;; view the results\nprofiler:reset         ;; clear the data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
245
477
366
510
sneaker_thresh
sneaker_thresh
0.6
0.9
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
245
513
367
546
sneaker_boost
sneaker_boost
0
300
300.0
5
1
NIL
HORIZONTAL

CHOOSER
476
479
614
524
n-loci-sign
n-loci-sign
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
0

MONITOR
9
150
104
195
Current time
;time:show current-time \"yyyy-MM-dd\"\nmy-week
17
1
11

TEXTBOX
482
535
632
577
controls the number of loci that have a different sign in the males
11
0.0
1

MONITOR
1223
367
1306
412
max sea age
max [sea-time] of turtles with [pcolor = blue]
17
1
11

MONITOR
895
444
963
489
Prop anad
count turtles with [anadromous = true] / count turtles
2
1
11

SLIDER
245
552
368
585
sneaker_radius
sneaker_radius
0
5
5.0
1
1
NIL
HORIZONTAL

SWITCH
476
441
588
474
evolution?
evolution?
0
1
-1000

INPUTBOX
244
596
399
656
lifespan
416.0
1
0
Number

TEXTBOX
409
597
559
653
260 = 5 years in weeks\n312 = 6 years in weeks\n364 = 7 years in weeks\n416 = 8 years in weeks\n
11
0.0
1

MONITOR
688
763
776
808
Spawners res
count turtles with [anadromous = False and FecAcc > 0]
17
1
11

MONITOR
775
763
873
808
Spawners anad
count turtles with [anadromous = True and FecAcc > 0]
17
1
11

PLOT
978
561
1266
748
Strategy spawners
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Resid" 1.0 0 -13345367 true "" "plot count turtles with [anadromous = False and FecAcc > 0]"
"Anad" 1.0 0 -2674135 true "" "plot count turtles with [anadromous = True and FecAcc > 0]"

MONITOR
872
763
973
808
Prop anad/resid
count turtles with [anadromous = True and FecAcc > 0] / count turtles with [anadromous = False and FecAcc > 0]
5
1
11

PLOT
674
562
967
749
Prop spawners anad / resid
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "ifelse (count turtles with [anadromous = False and FecAcc > 0]) > 0\n[plot count turtles with [anadromous = True and FecAcc > 0] / count turtles with [anadromous = False and FecAcc > 0]]\n[plot 0]"
"pen-1" 1.0 0 -16777216 true "" "plot 1"

TEXTBOX
422
808
572
826
Quality parameters
11
0.0
1

INPUTBOX
6
727
119
787
Fec-reduction-resid
1.0
1
0
Number

TEXTBOX
130
729
200
785
Relative reduction in fecundity due to residency
11
0.0
1

MONITOR
678
490
820
535
Mean Prop anad 100 yr
mean anad-tactic-ratio-list
3
1
11

MONITOR
821
490
948
535
CV Prop anad 100 yr
standard-deviation anad-tactic-ratio-list / mean anad-tactic-ratio-list
3
1
11

SWITCH
119
43
244
76
Check-Stability?
Check-Stability?
0
1
-1000

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
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>if my-week = 47 and year &gt; 99 [count turtles]</metric>
    <enumeratedValueSet variable="res_quality_sd">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carryingCapacity">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prop-parasites">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Fec-reduction-resid">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sneaker_radius">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="anad_quality_sd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-trout">
      <value value="6000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-loci-sign">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parasite-load">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="anad-death-multiplierM">
      <value value="1.06"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortalityF">
      <value value="0.02078"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortalityM">
      <value value="0.02078"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolution?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="res_quality_mean">
      <value value="175"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan">
      <value value="416"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="anad-death-multiplierF">
      <value value="1.06"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sneaker_boost">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-mate-radius">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sneaker_thresh">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sneaker?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paras_quality">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="anad_quality">
      <value value="235"/>
    </enumeratedValueSet>
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
0
@#$#@#$#@
