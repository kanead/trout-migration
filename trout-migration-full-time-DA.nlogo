; Trout Migration and Parasitism Model

; https://homepage.stat.uiowa.edu/~mbognar/applets/bin.html
; n = 40, p = 0.5 gives mean = 20, variance = 10
extensions [rnd time]
globals
[
  day
  year
  start-time
  current-time
  my-month
  my-day

] ;; added start-time and current-time

breed[males male]
breed[females female]
; breed[juveniles juvenile]

turtles-own
[
  mates
  prob-death
  sea-time
  state
  habitat

  gene1 gene2 gene3 gene4 gene5 gene6 gene7 gene8 gene9 gene10 gene11 gene12 gene13 gene14 gene15 gene16 gene17 gene18 gene19 gene20 gene21

  locus1.1 locus1.2 locus2.1 locus2.2 locus3.1 locus3.2 locus4.1 locus4.2 locus5.1 locus5.2 locus6.1 locus6.2 locus7.1 locus7.2 locus8.1 locus8.2
  locus9.1 locus9.2 locus10.1 locus10.2 locus11.1 locus11.2 locus12.1 locus12.2 locus13.1 locus13.2 locus14.1 locus14.2 locus15.1 locus15.2 locus16.1
  locus16.2 locus17.1 locus17.2 locus18.1 locus18.2 locus19.1 locus19.2 locus20.1 locus20.2 locus21.1 locus21.2

  G
  mu_thresh
  h2
  Vp
  Va
  Ve
  mu_cond
  V_cond
  cond
  e_thresh
  z_thresh
  anadromous

  mother
  father
  motherThresh
  fatherThresh

  quality
  age
  sex

;  my-day
;  my-month
]
males-own
[
;  mu_thresh
;  h2
;  Vp
;  Va
;  Ve
;  mu_cond
;  V_cond
;  e_threshM
;  z_threshM
;  condM
;  anadromous
;  mates
;  mother
;  father
;  motherThresh
;  fatherThresh
;  age
]
females-own
[
;  mu_thresh
;  h2
;  Vp
;  Va
;  Ve
;  mu_cond
;  V_cond
;  e_threshF
;  z_threshF
;  condF
;  anadromous
;  mates
  max-mate-count
  mate-count
  availa-males
;  mother
;  father
;  motherThresh
;  fatherThresh
;  age
  G-standardised
  days-since-child
]

patches-own [parasites?]


to setup
  clear-all

  ; time schedule
  set start-time time:create "2000-01-01"
  set current-time time:anchor-to-ticks start-time 1.0 "days"
  time:anchor-schedule start-time 1.0 "days"
  ;;

  ask patches [set pcolor cyan]
  ask patches with [pxcor >= 50] [set pcolor blue]

  let percentage prop-parasites
  let sea patches with [pcolor = blue]
  ask  n-of (percentage * count sea) sea
  [set  parasites? "yes"]

 ; ask n-of n-parasites patches with [pcolor = blue] [set  parasites? "yes"]
  ; create the population of trout
  ask n-of n-trout patches with [pcolor = cyan]
  [
   sprout 1
    [
    ifelse random 2 = 1
      [set breed males set sex "male" set color grey]
      [set breed females set sex "female" set color red]

    set state "healthy"
    set size 2         ; represents size of the fish on screen, purely aesthetic
    set sea-time 0
    set mu_cond  5     ; mean value of the condition trait
    set V_cond  1.17      ; variance of the condition trait (in this case, all the phenotypic variance is environmental)

  ]
]

  ask turtles
  [
    set locus1.1 random 2 set locus1.2 random 2   set gene1 list locus1.1 locus1.2
    set locus2.1 random 2 set locus2.2 random 2   set gene2 list locus2.1 locus2.2
    set locus3.1 random 2 set locus3.2 random 2   set gene3 list locus3.1 locus3.2
    set locus4.1 random 2 set locus4.2 random 2   set gene4 list locus4.1 locus4.2
    set locus5.1 random 2 set locus5.2 random 2   set gene5 list locus5.1 locus5.2
    set locus6.1 random 2 set locus6.2 random 2   set gene6 list locus6.1 locus6.2
    set locus7.1 random 2 set locus7.2 random 2   set gene7 list locus7.1 locus7.2
    set locus8.1 random 2 set locus8.2 random 2   set gene8 list locus8.1 locus8.2
    set locus9.1 random 2 set locus9.2 random 2   set gene9 list locus9.1 locus9.2
    set locus10.1 random 2 set locus10.2 random 2 set gene10 list locus10.1 locus10.2
    set locus11.1 random 2 set locus11.2 random 2 set gene11 list locus11.1 locus11.2
    set locus12.1 random 2 set locus12.2 random 2 set gene12 list locus12.1 locus12.2
    set locus13.1 random 2 set locus13.2 random 2 set gene13 list locus13.1 locus13.2
    set locus14.1 random 2 set locus14.2 random 2 set gene14 list locus14.1 locus14.2
    set locus15.1 random 2 set locus15.2 random 2 set gene15 list locus15.1 locus15.2
    set locus16.1 random 2 set locus16.2 random 2 set gene16 list locus16.1 locus16.2
    set locus17.1 random 2 set locus17.2 random 2 set gene17 list locus17.1 locus17.2
    set locus18.1 random 2 set locus18.2 random 2 set gene18 list locus18.1 locus18.2
    set locus19.1 random 2 set locus19.2 random 2 set gene19 list locus19.1 locus19.2
    set locus20.1 random 2 set locus20.2 random 2 set gene20 list locus20.1 locus20.2
    set locus21.1 0 set locus21.2 0 ; neutral marker gets a 0 at both loci
    set gene21 list locus21.1 locus21.2

    set-migratory-behaviour
  ]


  reset-ticks
end


to go
  if ticks mod 364 = 0 [set year year + 1]
  if year = 500 [ stop]
  set my-month  time:get "month" current-time
  set my-day  time:get "day" current-time

  ;if ticks mod 3640 = 0  [allele-freq]

  if count turtles > carrying-capacity [grim-reaper]

  ask turtles
  [
;    set my-month  time:get "month" current-time
;    set my-day  time:get "day" current-time
    set mates ( turtle-set )
    if habitat = "fresh" [ move-to one-of patches with [pcolor = cyan] ]
    set age (1 + age)  ;increment-age
    mortality
    if anadromous  [migrate]
  ]

  ask females [ set days-since-child days-since-child + 1 ]

  ask females
   [
      ifelse age > 365 and  my-month = 2 and pcolor = cyan
      [choose-mates]
      [set mate-count 0]
   ]

  ask females with [age > 0 and  pcolor = cyan and  my-month = 2 and days-since-child >= 365] [reproduce]

  tick
end

to set-migratory-behaviour
  ;; This mathematical operation can be optimzed in terms of space: weight1*(locus1.1+locus1.2), and so on...
  set G   (weight1 * locus1.1) + (weight1 * locus1.2) + (weight2 * locus2.1) + weight2 * (locus2.2) + (weight3 * locus3.1) + (weight3 * locus3.2) + (weight4 * locus4.1) + (weight4 * locus4.2)
      + (weight5 * locus5.1) + (weight5 * locus5.2) + (weight6 * locus6.1) + (weight6 * locus6.2) + (weight7 * locus7.1) + (weight7 * locus7.2) + (weight8 * locus8.1) + (weight8 * locus8.2)
      + (weight9 * locus9.1) + (weight9 * locus9.2) + (weight10 * locus10.1) + (weight10 * locus10.2) + (weight11 * locus11.1) + (weight11 * locus11.2) + (weight12 * locus12.1) + (weight12 * locus12.2)
      + (weight13 * locus13.1) + (weight13 * locus13.2) + (weight14 * locus14.1) + (weight14 * locus14.2) + (weight15 * locus15.1) + (weight15 * locus15.2) + (weight16 * locus16.1) + (weight16 * locus16.2)
      + (weight17 * locus17.1) + (weight17 * locus17.2) + (weight18 * locus18.1) + (weight18 * locus18.2) + (weight19 * locus19.1) + (weight19 * locus19.2) + (weight20 * locus20.1) + (weight20 * locus20.2) ; + locus21.1 + locus21.2

    set Va 1.17
    set Ve 1.17
    set Vp 2.34

    if conflict? and sex = "male"
     [
        set G  (G - ((weight1 * locus1.1) + (weight1 * locus1.2)) + ((weight1 * locus1.1 * -1) + (weight1 * locus1.2 * -1)))
        set Va 1.17
        set Ve 1.17
        set Vp 2.34
     ]

    set e_thresh random-normal 0 (sqrt(Ve))
    set z_thresh G + e_thresh
    set cond random-normal mu_cond  sqrt(V_cond)
    ifelse(cond > z_thresh)
     [set anadromous false  set quality random-normal res_quality_mean res_quality_sd] ; 100 10
     [set anadromous true set quality random-normal anad_quality_mean anad_quality_sd] ; 200 10
    set habitat "fresh"
end


to migrate
  if age > 365 and my-month = 1 and my-day = 1
   [
    move-to one-of patches with [pcolor = blue]
    set habitat "marine"
   ]
  if pcolor = blue [ set sea-time sea-time + 1]
  if my-month = 1 and my-day = 2 and sea-time > 700
   [
    move-to one-of patches with [pcolor = cyan]
    set habitat "fresh"
   ]
  if pcolor = cyan [ set sea-time 0]
  if parasites? = "yes"
   [
     set state "parasitised"
     set quality random-normal paras_quality_mean paras_quality_sd ; 150 10
   ]
end

;to increment-age
;  set age (1 + age)
;end

to mortality ;. mortality procedure, varies for males, females, anadromous and resident
  ask males
   [
    ifelse pcolor = cyan
     [set prob-death mortalityM ; chance of dying on any turn in freshwater
      if random-float 1 < prob-death [die] ] ; death procedure
     [
      ifelse state = "healthy"
        [ set prob-death mortalityM * anad-death-multiplierM  ]                 ; higher likelihood of death while anadromous
        [ set prob-death mortalityM * anad-death-multiplierM * parasite-load ]  ; higher likelihood again of dying if parasitized while at sea
      ]
     if random-float 1 < prob-death [die] ; death procedure
    ]

  ask females
    [
     ifelse pcolor = cyan
      [set prob-death mortalityF ; chance of dying on any turn in freshwater
        if random-float 1 < prob-death [die] ] ; death procedure
      [
       ifelse state = "healthy"
        [ set prob-death mortalityF * anad-death-multiplierF ]  ; higher likelihood of death while anadromous
        [ set prob-death mortalityF * anad-death-multiplierF * parasite-load ] ; higher likelihood again of dying if parasitized while at sea
      ]
     if random-float 1 < prob-death [die] ; death procedure
    ]

end

to choose-mates ; females choose up to 5 male mates from a pool in their radius
                ; they preferentially select residents disproportionate to availability

;  ask females
;  [
    ; set a cap on possible mates for females; 5, or the number
    ; available within the radius if less than 5

    set availa-males males in-radius female-mate-radius with [pcolor = cyan and age > 365]
    let n-max count availa-males
    set max-mate-count ifelse-value ( n-max < 5 ) [ n-max ] [ 5 ] ; 5 5

    ; Until a female has chosen up to her maximum number of mates:
    while [ mate-count < max-mate-count ]
     [
      ; determine which available males are not already in her 'mates' agentset
      set availa-males availa-males with [ not member? self [mates] of myself ]

      ; assess the proportion of resident strategy in remaining available males
      let prop_B ( count availa-males with [ anadromous = false ] ) / n-max


      ; example probability choice, just meant to choose B males
      ; with a frequency disproportionate to availability
      let proba_B ifelse-value ( prop_B <= 0.1 ) [ sneaker_yes ] [ sneaker_no ] ; if residents make up x% or less of the mating pool select them according to the first box, if greater select, according to the second

      ; use a random float to determine which strategy type is chosen
      set mates ( turtle-set mates
        ifelse-value ( random-float 1 < proba_B )
        [ one-of availa-males with [ anadromous = false] ]
        [ rnd:weighted-one-of availa-males with [ anadromous = true ] [ quality ]]  )

      ; count the current mates to break the while loop once
      ; the maximum number of mates is reached
      set mate-count count mates
    ]      ; have the female's males add her to their own mates agentset

    ask mates [ set mates ( turtle-set mates myself ) ]

    if n-max < count mates [ print  "Fewer available males than mates" ]

    ;  set a_threshM [a_threshM] of mates

 ;    ]
end


to reproduce ; females produce 5 offspring which inherit traits from their parents
             ; the father traits are chosen from one of the female's mates
  if count mates > 0
   [
    ifelse anadromous = false
      [
        set days-since-child 0
        let L  10
        let k  0.04
        let mass0  150
        let fecundity   L / (1 + exp(- k * (quality - mass0)))
        hatch round fecundity
        [
          set mother myself
          set father one-of [mates] of mother
          ;   set motherThresh [a_threshF] of mother
          ;   set fatherThresh sum n-of 1 [a_threshM] of mother
          set locus1.1 one-of [gene1] of mother    set locus1.2 one-of [gene1] of father    set gene1  list locus1.1 locus1.2
          set locus2.1 one-of [gene2] of mother    set locus2.2 one-of [gene2] of father    set gene2  list locus2.1 locus2.2
          set locus3.1 one-of [gene3] of mother    set locus3.2 one-of [gene3] of father    set gene3  list locus3.1 locus3.2
          set locus4.1 one-of [gene4] of mother    set locus4.2 one-of [gene4] of father    set gene4  list locus4.1 locus4.2
          set locus5.1 one-of [gene5] of mother    set locus5.2 one-of [gene5] of father    set gene5  list locus5.1 locus5.2
          set locus6.1 one-of [gene6] of mother    set locus6.2 one-of [gene6] of father    set gene6  list locus6.1 locus6.2
          set locus7.1 one-of [gene7] of mother    set locus7.2 one-of [gene7] of father    set gene7  list locus7.1 locus7.2
          set locus8.1 one-of [gene8] of mother    set locus8.2 one-of [gene8] of father    set gene8  list locus8.1 locus8.2
          set locus9.1 one-of [gene9] of mother    set locus9.2 one-of [gene9] of father    set gene9  list locus9.1 locus9.2
          set locus10.1 one-of [gene10] of mother  set locus10.2 one-of [gene10] of father  set gene10  list locus10.1 locus10.2
          set locus11.1 one-of [gene11] of mother  set locus11.2 one-of [gene11] of father  set gene11  list locus11.1 locus11.2
          set locus12.1 one-of [gene12] of mother  set locus12.2 one-of [gene12] of father  set gene12  list locus12.1 locus12.2
          set locus13.1 one-of [gene13] of mother  set locus13.2 one-of [gene13] of father  set gene13  list locus13.1 locus13.2
          set locus14.1 one-of [gene14] of mother  set locus14.2 one-of [gene14] of father  set gene14  list locus14.1 locus14.2
          set locus15.1 one-of [gene15] of mother  set locus15.2 one-of [gene15] of father  set gene15  list locus15.1 locus15.2
          set locus16.1 one-of [gene16] of mother  set locus16.2 one-of [gene16] of father  set gene16  list locus16.1 locus16.2
          set locus17.1 one-of [gene17] of mother  set locus17.2 one-of [gene17] of father  set gene17  list locus17.1 locus17.2
          set locus18.1 one-of [gene18] of mother  set locus18.2 one-of [gene18] of father  set gene18  list locus18.1 locus18.2
          set locus19.1 one-of [gene19] of mother  set locus19.2 one-of [gene19] of father  set gene19  list locus19.1 locus19.2
          set locus20.1 one-of [gene20] of mother  set locus20.2 one-of [gene20] of father  set gene20  list locus20.1 locus20.2
          set locus21.1 one-of [gene21] of mother  set locus21.2 one-of [gene21] of father  set gene21  list locus21.1 locus21.2

          set state "healthy"
          ifelse random 2 = 1
           [
            set breed males
            set color red
            set sex "male"
           ]
           [
            set breed females
            set color grey
            set sex "female"
           ]

          set-migratory-behaviour

        ] ; ask mates [die]   ; fathers die after mating
    ; die               ; mothers die after mating
      ]

      [
        set days-since-child 0
        let L  10
        let k  0.04
        let mass0  150
        let fecundity   L / (1 + exp(- k * (quality - mass0)))
        hatch round fecundity
        [
          set mother myself
          set father one-of [mates] of mother
          ;   set motherThresh [a_threshF] of mother
          ;   set fatherThresh sum n-of 1 [a_threshM] of mother
          set locus1.1 one-of [gene1] of mother    set locus1.2 one-of [gene1] of father    set gene1  list locus1.1 locus1.2
          set locus2.1 one-of [gene2] of mother    set locus2.2 one-of [gene2] of father    set gene2  list locus2.1 locus2.2
          set locus3.1 one-of [gene3] of mother    set locus3.2 one-of [gene3] of father    set gene3  list locus3.1 locus3.2
          set locus4.1 one-of [gene4] of mother    set locus4.2 one-of [gene4] of father    set gene4  list locus4.1 locus4.2
          set locus5.1 one-of [gene5] of mother    set locus5.2 one-of [gene5] of father    set gene5  list locus5.1 locus5.2
          set locus6.1 one-of [gene6] of mother    set locus6.2 one-of [gene6] of father    set gene6  list locus6.1 locus6.2
          set locus7.1 one-of [gene7] of mother    set locus7.2 one-of [gene7] of father    set gene7  list locus7.1 locus7.2
          set locus8.1 one-of [gene8] of mother    set locus8.2 one-of [gene8] of father    set gene8  list locus8.1 locus8.2
          set locus9.1 one-of [gene9] of mother    set locus9.2 one-of [gene9] of father    set gene9  list locus9.1 locus9.2
          set locus10.1 one-of [gene10] of mother  set locus10.2 one-of [gene10] of father  set gene10  list locus10.1 locus10.2
          set locus11.1 one-of [gene11] of mother  set locus11.2 one-of [gene11] of father  set gene11  list locus11.1 locus11.2
          set locus12.1 one-of [gene12] of mother  set locus12.2 one-of [gene12] of father  set gene12  list locus12.1 locus12.2
          set locus13.1 one-of [gene13] of mother  set locus13.2 one-of [gene13] of father  set gene13  list locus13.1 locus13.2
          set locus14.1 one-of [gene14] of mother  set locus14.2 one-of [gene14] of father  set gene14  list locus14.1 locus14.2
          set locus15.1 one-of [gene15] of mother  set locus15.2 one-of [gene15] of father  set gene15  list locus15.1 locus15.2
          set locus16.1 one-of [gene16] of mother  set locus16.2 one-of [gene16] of father  set gene16  list locus16.1 locus16.2
          set locus17.1 one-of [gene17] of mother  set locus17.2 one-of [gene17] of father  set gene17  list locus17.1 locus17.2
          set locus18.1 one-of [gene18] of mother  set locus18.2 one-of [gene18] of father  set gene18  list locus18.1 locus18.2
          set locus19.1 one-of [gene19] of mother  set locus19.2 one-of [gene19] of father  set gene19  list locus19.1 locus19.2
          set locus20.1 one-of [gene20] of mother  set locus20.2 one-of [gene20] of father  set gene20  list locus20.1 locus20.2
          set locus21.1 one-of [gene21] of mother  set locus21.2 one-of [gene21] of father  set gene21  list locus21.1 locus21.2

          set state "healthy"
          ifelse random 2 = 1
           [
            set breed males
            set color red
            set sex "male"
           ]
           [
            set breed females
            set color grey
            set sex "female"
           ]

          set-migratory-behaviour

          ]
        ]; ask mates [die]   ; fathers die after mating
         ; die               ; mothers die after mating
      ]
end

;; kill turtles in excess of carrying capacity
to grim-reaper
  let num-turtles count turtles
;  if num-turtles <= carrying-capacity [ stop ]
  let chance-to-die (num-turtles - carrying-capacity) / num-turtles
  ask turtles with [pcolor = cyan]
   [
    if random-float 1.0 < chance-to-die [ die ]
   ]
end

; to-print  allele-freq
; ifelse (ticks mod 365) = 0
 to allele-freq ;
;to-print allele-freq
print count turtles with [locus1.1 = 1 and locus1.2 = 1] / count turtles
print count turtles with [locus1.1 = 1 and locus1.2 = 0] / count turtles
+ count turtles with [locus1.1 = 0 and locus1.2 = 1] / count turtles
print count turtles with [locus1.1 = 0 and locus1.2 = 0] / count turtles

print count turtles with [locus2.1 = 1 and locus2.2 = 1] / count turtles
print count turtles with [locus2.1 = 1 and locus2.2 = 0] / count turtles
+ count turtles with [locus2.1 = 0 and locus2.2 = 1] / count turtles
print count turtles with [locus2.1 = 0 and locus2.2 = 0] / count turtles

print count turtles with [locus3.1 = 1 and locus3.2 = 1] / count turtles
print count turtles with [locus3.1 = 1 and locus3.2 = 0] / count turtles
+ count turtles with [locus3.1 = 0 and locus3.2 = 1] / count turtles
print count turtles with [locus3.1 = 0 and locus3.2 = 0] / count turtles

print count turtles with [locus4.1 = 1 and locus4.2 = 1] / count turtles
print count turtles with [locus4.1 = 1 and locus4.2 = 0] / count turtles
+  count turtles with [locus4.1 = 0 and locus4.2 = 1] / count turtles
print count turtles with [locus4.1 = 0 and locus4.2 = 0] / count turtles

print count turtles with [locus5.1 = 1 and locus5.2 = 1] / count turtles
print count turtles with [locus5.1 = 1 and locus5.2 = 0] / count turtles
+  count turtles with [locus5.1 = 0 and locus5.2 = 1] / count turtles
print count turtles with [locus5.1 = 0 and locus5.2 = 0] / count turtles

print count turtles with [locus6.1 = 1 and locus6.2 = 1] / count turtles
print count turtles with [locus6.1 = 1 and locus6.2 = 0] / count turtles
+  count turtles with [locus6.1 = 0 and locus6.2 = 1] / count turtles
print count turtles with [locus6.1 = 0 and locus6.2 = 0] / count turtles

print count turtles with [locus7.1 = 1 and locus7.2 = 1] / count turtles
print count turtles with [locus7.1 = 1 and locus7.2 = 0] / count turtles
+  count turtles with [locus7.1 = 0 and locus7.2 = 1] / count turtles
print count turtles with [locus7.1 = 0 and locus7.2 = 0] / count turtles

print count turtles with [locus8.1 = 1 and locus8.2 = 1] / count turtles
print count turtles with [locus8.1 = 1 and locus8.2 = 0] / count turtles
+  count turtles with [locus8.1 = 0 and locus8.2 = 1] / count turtles
print count turtles with [locus8.1 = 0 and locus8.2 = 0] / count turtles

print count turtles with [locus9.1 = 1 and locus9.2 = 1] / count turtles
print count turtles with [locus9.1 = 1 and locus9.2 = 0] / count turtles
+  count turtles with [locus9.1 = 0 and locus9.2 = 1] / count turtles
print count turtles with [locus9.1 = 0 and locus9.2 = 0] / count turtles

print count turtles with [locus10.1 = 1 and locus10.2 = 1] / count turtles
print count turtles with [locus10.1 = 1 and locus10.2 = 0] / count turtles
+  count turtles with [locus10.1 = 0 and locus10.2 = 1] / count turtles
print count turtles with [locus10.1 = 0 and locus10.2 = 0] / count turtles

print count turtles with [locus11.1 = 1 and locus11.2 = 1] / count turtles
print count turtles with [locus11.1 = 1 and locus11.2 = 0] / count turtles
+  count turtles with [locus11.1 = 0 and locus11.2 = 1] / count turtles
print count turtles with [locus11.1 = 0 and locus11.2 = 0] / count turtles

print count turtles with [locus12.1 = 1 and locus12.2 = 1] / count turtles
print count turtles with [locus12.1 = 1 and locus12.2 = 0] / count turtles
+  count turtles with [locus12.1 = 0 and locus12.2 = 1] / count turtles
print count turtles with [locus12.1 = 0 and locus12.2 = 0] / count turtles

print count turtles with [locus13.1 = 1 and locus13.2 = 1] / count turtles
print count turtles with [locus13.1 = 1 and locus13.2 = 0] / count turtles
+  count turtles with [locus13.1 = 0 and locus13.2 = 1] / count turtles
print count turtles with [locus13.1 = 0 and locus13.2 = 0] / count turtles

print count turtles with [locus14.1 = 1 and locus14.2 = 1] / count turtles
print count turtles with [locus14.1 = 1 and locus14.2 = 0] / count turtles
+  count turtles with [locus14.1 = 0 and locus14.2 = 1] / count turtles
print count turtles with [locus14.1 = 0 and locus14.2 = 0] / count turtles

print count turtles with [locus15.1 = 1 and locus15.2 = 1] / count turtles
print count turtles with [locus15.1 = 1 and locus15.2 = 0] / count turtles
+  count turtles with [locus15.1 = 0 and locus15.2 = 1] / count turtles
print count turtles with [locus15.1 = 0 and locus15.2 = 0] / count turtles

print count turtles with [locus16.1 = 1 and locus16.2 = 1] / count turtles
print count turtles with [locus16.1 = 1 and locus16.2 = 0] / count turtles
+  count turtles with [locus16.1 = 0 and locus16.2 = 1] / count turtles
print count turtles with [locus16.1 = 0 and locus16.2 = 0] / count turtles

print count turtles with [locus17.1 = 1 and locus17.2 = 1] / count turtles
print count turtles with [locus17.1 = 1 and locus17.2 = 0] / count turtles
+  count turtles with [locus17.1 = 0 and locus17.2 = 1] / count turtles
print count turtles with [locus17.1 = 0 and locus17.2 = 0] / count turtles

print count turtles with [locus18.1 = 1 and locus18.2 = 1] / count turtles
print count turtles with [locus18.1 = 1 and locus18.2 = 0] / count turtles
+  count turtles with [locus18.1 = 0 and locus18.2 = 1] / count turtles
print count turtles with [locus18.1 = 0 and locus18.2 = 0] / count turtles

print count turtles with [locus19.1 = 1 and locus19.2 = 1] / count turtles
print count turtles with [locus19.1 = 1 and locus19.2 = 0] / count turtles
+  count turtles with [locus19.1 = 0 and locus19.2 = 1] / count turtles
print count turtles with [locus19.1 = 0 and locus19.2 = 0] / count turtles

print count turtles with [locus20.1 = 1 and locus20.2 = 1] / count turtles
print count turtles with [locus20.1 = 1 and locus20.2 = 0] / count turtles
+  count turtles with [locus20.1 = 0 and locus20.2 = 1] / count turtles
print count turtles with [locus20.1 = 0 and locus20.2 = 0] / count turtles

print count turtles with [locus21.1 = 1 and locus21.2 = 1] / count turtles
print count turtles with [locus21.1 = 1 and locus21.2 = 0] / count turtles
+  count turtles with [locus21.1 = 0 and locus21.2 = 1] / count turtles
print count turtles with [locus21.1 = 0 and locus21.2 = 0] / count turtles

print count males with [anadromous = true] / count males
print count females with [anadromous = true] / count females

print [g] of males
print [g] of females
; ; [report "gap"]; where "" is an empty placeholder text that you may ignore.
end

; to-print  allele-freq
; ifelse (ticks mod 365) = 0
 to allele-freq-by-sex ;
;to-print allele-freq
print count males with [locus1.1 = 1 and locus1.2 = 1] / count males
print count males with [locus1.1 = 1 and locus1.2 = 0] / count males
+ count males with [locus1.1 = 0 and locus1.2 = 1] / count males
print count males with [locus1.1 = 0 and locus1.2 = 0] / count males

print count males with [locus2.1 = 1 and locus2.2 = 1] / count males
print count males with [locus2.1 = 1 and locus2.2 = 0] / count males
+ count males with [locus2.1 = 0 and locus2.2 = 1] / count males
print count males with [locus2.1 = 0 and locus2.2 = 0] / count males

print count males with [locus3.1 = 1 and locus3.2 = 1] / count males
print count males with [locus3.1 = 1 and locus3.2 = 0] / count males
+ count males with [locus3.1 = 0 and locus3.2 = 1] / count males
print count males with [locus3.1 = 0 and locus3.2 = 0] / count males

print count males with [locus4.1 = 1 and locus4.2 = 1] / count males
print count males with [locus4.1 = 1 and locus4.2 = 0] / count males
+  count males with [locus4.1 = 0 and locus4.2 = 1] / count males
print count males with [locus4.1 = 0 and locus4.2 = 0] / count males

print count males with [locus5.1 = 1 and locus5.2 = 1] / count males
print count males with [locus5.1 = 1 and locus5.2 = 0] / count males
+  count males with [locus5.1 = 0 and locus5.2 = 1] / count males
print count males with [locus5.1 = 0 and locus5.2 = 0] / count males

print count males with [locus6.1 = 1 and locus6.2 = 1] / count males
print count males with [locus6.1 = 1 and locus6.2 = 0] / count males
+  count males with [locus6.1 = 0 and locus6.2 = 1] / count males
print count males with [locus6.1 = 0 and locus6.2 = 0] / count males

print count males with [locus7.1 = 1 and locus7.2 = 1] / count males
print count males with [locus7.1 = 1 and locus7.2 = 0] / count males
+  count males with [locus7.1 = 0 and locus7.2 = 1] / count males
print count males with [locus7.1 = 0 and locus7.2 = 0] / count males

print count males with [locus8.1 = 1 and locus8.2 = 1] / count males
print count males with [locus8.1 = 1 and locus8.2 = 0] / count males
+  count males with [locus8.1 = 0 and locus8.2 = 1] / count males
print count males with [locus8.1 = 0 and locus8.2 = 0] / count males

print count males with [locus9.1 = 1 and locus9.2 = 1] / count males
print count males with [locus9.1 = 1 and locus9.2 = 0] / count males
+  count males with [locus9.1 = 0 and locus9.2 = 1] / count males
print count males with [locus9.1 = 0 and locus9.2 = 0] / count males

print count males with [locus10.1 = 1 and locus10.2 = 1] / count males
print count males with [locus10.1 = 1 and locus10.2 = 0] / count males
+  count males with [locus10.1 = 0 and locus10.2 = 1] / count males
print count males with [locus10.1 = 0 and locus10.2 = 0] / count males

print count males with [locus11.1 = 1 and locus11.2 = 1] / count males
print count males with [locus11.1 = 1 and locus11.2 = 0] / count males
+  count males with [locus11.1 = 0 and locus11.2 = 1] / count males
print count males with [locus11.1 = 0 and locus11.2 = 0] / count males

print count males with [locus12.1 = 1 and locus12.2 = 1] / count males
print count males with [locus12.1 = 1 and locus12.2 = 0] / count males
+  count males with [locus12.1 = 0 and locus12.2 = 1] / count males
print count males with [locus12.1 = 0 and locus12.2 = 0] / count males

print count males with [locus13.1 = 1 and locus13.2 = 1] / count males
print count males with [locus13.1 = 1 and locus13.2 = 0] / count males
+  count males with [locus13.1 = 0 and locus13.2 = 1] / count males
print count males with [locus13.1 = 0 and locus13.2 = 0] / count males

print count males with [locus14.1 = 1 and locus14.2 = 1] / count males
print count males with [locus14.1 = 1 and locus14.2 = 0] / count males
+  count males with [locus14.1 = 0 and locus14.2 = 1] / count males
print count males with [locus14.1 = 0 and locus14.2 = 0] / count males

print count males with [locus15.1 = 1 and locus15.2 = 1] / count males
print count males with [locus15.1 = 1 and locus15.2 = 0] / count males
+  count males with [locus15.1 = 0 and locus15.2 = 1] / count males
print count males with [locus15.1 = 0 and locus15.2 = 0] / count males

print count males with [locus16.1 = 1 and locus16.2 = 1] / count males
print count males with [locus16.1 = 1 and locus16.2 = 0] / count males
+  count males with [locus16.1 = 0 and locus16.2 = 1] / count males
print count males with [locus16.1 = 0 and locus16.2 = 0] / count males

print count males with [locus17.1 = 1 and locus17.2 = 1] / count males
print count males with [locus17.1 = 1 and locus17.2 = 0] / count males
+  count males with [locus17.1 = 0 and locus17.2 = 1] / count males
print count males with [locus17.1 = 0 and locus17.2 = 0] / count males

print count males with [locus18.1 = 1 and locus18.2 = 1] / count males
print count males with [locus18.1 = 1 and locus18.2 = 0] / count males
+  count males with [locus18.1 = 0 and locus18.2 = 1] / count males
print count males with [locus18.1 = 0 and locus18.2 = 0] / count males

print count males with [locus19.1 = 1 and locus19.2 = 1] / count males
print count males with [locus19.1 = 1 and locus19.2 = 0] / count males
+  count males with [locus19.1 = 0 and locus19.2 = 1] / count males
print count males with [locus19.1 = 0 and locus19.2 = 0] / count males

print count males with [locus20.1 = 1 and locus20.2 = 1] / count males
print count males with [locus20.1 = 1 and locus20.2 = 0] / count males
+  count males with [locus20.1 = 0 and locus20.2 = 1] / count males
print count males with [locus20.1 = 0 and locus20.2 = 0] / count males

print count males with [locus21.1 = 1 and locus21.2 = 1] / count males
print count males with [locus21.1 = 1 and locus21.2 = 0] / count males
+  count males with [locus21.1 = 0 and locus21.2 = 1] / count males
print count males with [locus21.1 = 0 and locus21.2 = 0] / count males


  print count females with [locus1.1 = 1 and locus1.2 = 1] / count females
print count females with [locus1.1 = 1 and locus1.2 = 0] / count females
+ count females with [locus1.1 = 0 and locus1.2 = 1] / count females
print count females with [locus1.1 = 0 and locus1.2 = 0] / count females

print count females with [locus2.1 = 1 and locus2.2 = 1] / count females
print count females with [locus2.1 = 1 and locus2.2 = 0] / count females
+ count females with [locus2.1 = 0 and locus2.2 = 1] / count females
print count females with [locus2.1 = 0 and locus2.2 = 0] / count females

print count females with [locus3.1 = 1 and locus3.2 = 1] / count females
print count females with [locus3.1 = 1 and locus3.2 = 0] / count females
+ count females with [locus3.1 = 0 and locus3.2 = 1] / count females
print count females with [locus3.1 = 0 and locus3.2 = 0] / count females

print count females with [locus4.1 = 1 and locus4.2 = 1] / count females
print count females with [locus4.1 = 1 and locus4.2 = 0] / count females
+  count females with [locus4.1 = 0 and locus4.2 = 1] / count females
print count females with [locus4.1 = 0 and locus4.2 = 0] / count females

print count females with [locus5.1 = 1 and locus5.2 = 1] / count females
print count females with [locus5.1 = 1 and locus5.2 = 0] / count females
+  count females with [locus5.1 = 0 and locus5.2 = 1] / count females
print count females with [locus5.1 = 0 and locus5.2 = 0] / count females

print count females with [locus6.1 = 1 and locus6.2 = 1] / count females
print count females with [locus6.1 = 1 and locus6.2 = 0] / count females
+  count females with [locus6.1 = 0 and locus6.2 = 1] / count females
print count females with [locus6.1 = 0 and locus6.2 = 0] / count females

print count females with [locus7.1 = 1 and locus7.2 = 1] / count females
print count females with [locus7.1 = 1 and locus7.2 = 0] / count females
+  count females with [locus7.1 = 0 and locus7.2 = 1] / count females
print count females with [locus7.1 = 0 and locus7.2 = 0] / count females

print count females with [locus8.1 = 1 and locus8.2 = 1] / count females
print count females with [locus8.1 = 1 and locus8.2 = 0] / count females
+  count females with [locus8.1 = 0 and locus8.2 = 1] / count females
print count females with [locus8.1 = 0 and locus8.2 = 0] / count females

print count females with [locus9.1 = 1 and locus9.2 = 1] / count females
print count females with [locus9.1 = 1 and locus9.2 = 0] / count females
+  count females with [locus9.1 = 0 and locus9.2 = 1] / count females
print count females with [locus9.1 = 0 and locus9.2 = 0] / count females

print count females with [locus10.1 = 1 and locus10.2 = 1] / count females
print count females with [locus10.1 = 1 and locus10.2 = 0] / count females
+  count females with [locus10.1 = 0 and locus10.2 = 1] / count females
print count females with [locus10.1 = 0 and locus10.2 = 0] / count females

print count females with [locus11.1 = 1 and locus11.2 = 1] / count females
print count females with [locus11.1 = 1 and locus11.2 = 0] / count females
+  count females with [locus11.1 = 0 and locus11.2 = 1] / count females
print count females with [locus11.1 = 0 and locus11.2 = 0] / count females

print count females with [locus12.1 = 1 and locus12.2 = 1] / count females
print count females with [locus12.1 = 1 and locus12.2 = 0] / count females
+  count females with [locus12.1 = 0 and locus12.2 = 1] / count females
print count females with [locus12.1 = 0 and locus12.2 = 0] / count females

print count females with [locus13.1 = 1 and locus13.2 = 1] / count females
print count females with [locus13.1 = 1 and locus13.2 = 0] / count females
+  count females with [locus13.1 = 0 and locus13.2 = 1] / count females
print count females with [locus13.1 = 0 and locus13.2 = 0] / count females

print count females with [locus14.1 = 1 and locus14.2 = 1] / count females
print count females with [locus14.1 = 1 and locus14.2 = 0] / count females
+  count females with [locus14.1 = 0 and locus14.2 = 1] / count females
print count females with [locus14.1 = 0 and locus14.2 = 0] / count females

print count females with [locus15.1 = 1 and locus15.2 = 1] / count females
print count females with [locus15.1 = 1 and locus15.2 = 0] / count females
+  count females with [locus15.1 = 0 and locus15.2 = 1] / count females
print count females with [locus15.1 = 0 and locus15.2 = 0] / count females

print count females with [locus16.1 = 1 and locus16.2 = 1] / count females
print count females with [locus16.1 = 1 and locus16.2 = 0] / count females
+  count females with [locus16.1 = 0 and locus16.2 = 1] / count females
print count females with [locus16.1 = 0 and locus16.2 = 0] / count females

print count females with [locus17.1 = 1 and locus17.2 = 1] / count females
print count females with [locus17.1 = 1 and locus17.2 = 0] / count females
+  count females with [locus17.1 = 0 and locus17.2 = 1] / count females
print count females with [locus17.1 = 0 and locus17.2 = 0] / count females

print count females with [locus18.1 = 1 and locus18.2 = 1] / count females
print count females with [locus18.1 = 1 and locus18.2 = 0] / count females
+  count females with [locus18.1 = 0 and locus18.2 = 1] / count females
print count females with [locus18.1 = 0 and locus18.2 = 0] / count females

print count females with [locus19.1 = 1 and locus19.2 = 1] / count females
print count females with [locus19.1 = 1 and locus19.2 = 0] / count females
+  count females with [locus19.1 = 0 and locus19.2 = 1] / count females
print count females with [locus19.1 = 0 and locus19.2 = 0] / count females

print count females with [locus20.1 = 1 and locus20.2 = 1] / count females
print count females with [locus20.1 = 1 and locus20.2 = 0] / count females
+  count females with [locus20.1 = 0 and locus20.2 = 1] / count females
print count females with [locus20.1 = 0 and locus20.2 = 0] / count females

print count females with [locus21.1 = 1 and locus21.2 = 1] / count females
print count females with [locus21.1 = 1 and locus21.2 = 0] / count females
+  count females with [locus21.1 = 0 and locus21.2 = 1] / count females
print count females with [locus21.1 = 0 and locus21.2 = 0] / count females

print count males with [anadromous = true] / count males
print count females with [anadromous = true] / count females

print [g] of males
print [g] of females
; ; [report "gap"]; where "" is an empty placeholder text that you may ignore.
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
count males
17
1
11

MONITOR
10
79
80
124
female trout
count females
17
1
11

SLIDER
10
43
141
76
n-trout
n-trout
0
5000
100.0
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
count males with [anadromous = true]
17
1
11

MONITOR
662
169
789
214
anadromous females
count females with [anadromous = true]
17
1
11

MONITOR
1062
167
1188
212
resident males
count males with [anadromous = false]
17
1
11

MONITOR
789
168
916
213
resident females
count females with [anadromous = false]
17
1
11

MONITOR
143
81
209
126
total trout 
count turtles
17
1
11

SLIDER
9
144
129
177
mortalityM
mortalityM
0
.004
1.0E-5
.00001
1
NIL
HORIZONTAL

INPUTBOX
11
181
142
241
anad-death-multiplierM
100.0
1
0
Number

MONITOR
148
33
205
78
NIL
year
17
1
11

SLIDER
10
261
131
294
mortalityF
mortalityF
0
0.004
1.0E-5
.00001
1
NIL
HORIZONTAL

INPUTBOX
6
318
138
378
anad-death-multiplierF
1.0
1
0
Number

SLIDER
8
431
180
464
female-mate-radius
female-mate-radius
0
100
0.0
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
"anad males" 1.0 0 -1184463 true "" "plot count males with [anadromous = true] / count turtles\n"
"res males" 1.0 0 -13345367 true "" "plot count males with [anadromous = false] / count turtles"
"anad fem" 1.0 0 -2674135 true "" "plot count females with [anadromous = true] / count turtles\n"
"res fem" 1.0 0 -10899396 true "" "plot count females with [anadromous = false] / count turtles"

SLIDER
7
464
179
497
carrying-capacity
carrying-capacity
0
100000
57325.0
1
1
NIL
HORIZONTAL

SLIDER
7
496
179
529
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
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.5 1 -16777216 true "" "histogram [G] of females"

PLOT
937
10
1137
160
G of males 
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
"default" 0.5 1 -16777216 true "" "histogram [G] of males "

SWITCH
423
436
526
469
conflict?
conflict?
1
1
-1000

INPUTBOX
3
540
158
600
parasite-load
0.0
1
0
Number

INPUTBOX
272
548
427
608
weight1
0.83734004
1
0
Number

INPUTBOX
432
549
587
609
weight2
0.70113835
1
0
Number

INPUTBOX
587
549
742
609
weight3
0.58709121
1
0
Number

INPUTBOX
742
549
897
609
weight4
0.49159498
1
0
Number

INPUTBOX
898
548
1053
608
weight5
0.41163216
1
0
Number

INPUTBOX
269
611
424
671
weight6
0.34467609
1
0
Number

INPUTBOX
429
612
584
672
weight7
0.28861109
1
0
Number

INPUTBOX
587
612
742
672
weight8
0.24166563
1
0
Number

INPUTBOX
747
611
902
671
weight9
0.2023563
1
0
Number

INPUTBOX
905
611
1060
671
weight10
0.16944104
1
0
Number

INPUTBOX
269
673
424
733
weight11
0.14187977
1
0
Number

INPUTBOX
427
672
582
732
weight12
0.11880161
1
0
Number

INPUTBOX
589
672
744
732
weight13
0.09947734
1
0
Number

INPUTBOX
749
672
904
732
weight14
0.08329636
1
0
Number

INPUTBOX
904
673
1059
733
weight15
0.06974738
1
0
Number

INPUTBOX
272
736
427
796
weight16
0.05840227
1
0
Number

INPUTBOX
428
736
583
796
weight17
0.04890256
1
0
Number

INPUTBOX
590
735
745
795
weight18
0.04094807
1
0
Number

INPUTBOX
747
735
902
795
weight19
0.03428746
1
0
Number

INPUTBOX
902
734
1057
794
weight20
0.02871027
1
0
Number

MONITOR
872
10
929
55
mean
mean [G] of females
5
1
11

MONITOR
870
56
930
101
variance
variance [G] of females
5
1
11

MONITOR
872
103
929
148
SD
standard-deviation [G] of females
5
1
11

MONITOR
1154
10
1215
55
mean
mean [G] of males
5
1
11

MONITOR
1155
56
1215
101
variance
variance [G] of males
5
1
11

MONITOR
1155
105
1214
150
SD
standard-deviation [G] of males
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
250.0
0.0
10.0
true
false
"" ""
PENS
"residents" 1.0 1 -2674135 true "" "histogram [quality] of males \n"

TEXTBOX
142
145
233
174
background mortality of males
11
0.0
1

TEXTBOX
145
264
237
316
background mortality of females
11
0.0
1

TEXTBOX
11
608
161
636
extra mortality due to parasites
11
0.0
1

TEXTBOX
542
442
692
460
sexual conflict 
11
0.0
1

TEXTBOX
147
322
232
387
extra mortality due to marine environ for females
11
0.0
1

TEXTBOX
152
186
230
250
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
250.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -7500403 true "" "histogram [quality] of females "

MONITOR
248
424
412
469
NIL
current-time
17
1
11

MONITOR
678
445
776
490
Prop anad male
count males with [anadromous = 1] / count males
3
1
11

MONITOR
781
444
891
489
Prop anad female
count females with [anadromous = 1] / count females
3
1
11

CHOOSER
9
700
147
745
sneaker_yes
sneaker_yes
0.9 0.5
1

CHOOSER
8
650
146
695
sneaker_no
sneaker_no
0.5 0.1
0

INPUTBOX
1134
546
1289
606
res_quality_mean
100.0
1
0
Number

INPUTBOX
1291
545
1446
605
res_quality_sd
10.0
1
0
Number

INPUTBOX
1136
668
1291
728
anad_quality_mean
200.0
1
0
Number

INPUTBOX
1293
668
1448
728
anad_quality_sd
10.0
1
0
Number

INPUTBOX
1136
608
1291
668
paras_quality_mean
150.0
1
0
Number

INPUTBOX
1290
607
1445
667
paras_quality_sd
10.0
1
0
Number

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
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <exitCondition>ticks = 3650</exitCondition>
    <metric>count turtles with [locus1.1 = 1 and locus1.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus1.1 = 1 and locus1.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus1.1 = 0 and locus1.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus1.1 = 0 and locus1.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus2.1 = 1 and locus2.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus2.1 = 1 and locus2.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus2.1 = 0 and locus2.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus2.1 = 0 and locus2.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus3.1 = 1 and locus3.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus3.1 = 1 and locus3.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus3.1 = 0 and locus3.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus3.1 = 0 and locus3.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus4.1 = 1 and locus4.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus4.1 = 1 and locus4.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus4.1 = 0 and locus4.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus4.1 = 0 and locus4.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus5.1 = 1 and locus5.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus5.1 = 1 and locus5.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus5.1 = 0 and locus5.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus5.1 = 0 and locus5.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus6.1 = 1 and locus6.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus6.1 = 1 and locus6.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus6.1 = 0 and locus6.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus6.1 = 0 and locus6.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus7.1 = 1 and locus7.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus7.1 = 1 and locus7.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus7.1 = 0 and locus7.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus7.1 = 0 and locus7.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus8.1 = 1 and locus8.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus8.1 = 1 and locus8.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus8.1 = 0 and locus8.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus8.1 = 0 and locus8.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus9.1 = 1 and locus9.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus9.1 = 1 and locus9.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus9.1 = 0 and locus9.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus9.1 = 0 and locus9.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus10.1 = 1 and locus10.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus10.1 = 1 and locus10.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus10.1 = 0 and locus10.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus10.1 = 0 and locus10.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus11.1 = 1 and locus11.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus11.1 = 1 and locus11.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus11.1 = 0 and locus11.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus11.1 = 0 and locus11.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus12.1 = 1 and locus12.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus12.1 = 1 and locus12.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus12.1 = 0 and locus12.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus12.1 = 0 and locus12.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus13.1 = 1 and locus13.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus13.1 = 1 and locus13.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus13.1 = 0 and locus13.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus13.1 = 0 and locus13.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus14.1 = 1 and locus14.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus14.1 = 1 and locus14.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus14.1 = 0 and locus14.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus14.1 = 0 and locus14.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus15.1 = 1 and locus15.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus15.1 = 1 and locus15.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus15.1 = 0 and locus15.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus15.1 = 0 and locus15.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus16.1 = 1 and locus16.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus16.1 = 1 and locus16.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus16.1 = 0 and locus16.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus16.1 = 0 and locus16.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus17.1 = 1 and locus17.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus17.1 = 1 and locus17.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus17.1 = 0 and locus17.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus17.1 = 0 and locus17.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus18.1 = 1 and locus18.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus18.1 = 1 and locus18.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus18.1 = 0 and locus18.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus18.1 = 0 and locus18.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus20.1 = 1 and locus20.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus20.1 = 1 and locus20.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus20.1 = 0 and locus20.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus20.1 = 0 and locus20.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus21.1 = 1 and locus21.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus21.1 = 1 and locus21.2 = 0] / count turtles</metric>
    <metric>count turtles with [locus21.1 = 0 and locus21.2 = 1] / count turtles</metric>
    <metric>count turtles with [locus21.1 = 0 and locus21.2 = 0] / count turtles</metric>
    <metric>count males with [anadromous = 1] / count males</metric>
    <metric>count females with [anadromous = 1] / count males</metric>
    <metric>[g] of males</metric>
    <metric>[g] of females</metric>
    <enumeratedValueSet variable="n-trout">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight9">
      <value value="0.2023563"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortalityM">
      <value value="1.0E-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight16">
      <value value="0.05840227"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight17">
      <value value="0.04890256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight18">
      <value value="0.04094807"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight5">
      <value value="0.41163216"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight19">
      <value value="0.03428746"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight6">
      <value value="0.34467609"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight20">
      <value value="0.02871027"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight12">
      <value value="0.11880161"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight7">
      <value value="0.28861109"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight8">
      <value value="0.24166563"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight13">
      <value value="0.09947734"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight14">
      <value value="0.08329636"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight1">
      <value value="0.83734004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prop-parasites">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight15">
      <value value="0.06974738"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight2">
      <value value="0.70113835"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight3">
      <value value="0.58709121"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parasite-load">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="anad-death-multiplierM">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortalityF">
      <value value="1.0E-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight4">
      <value value="0.49159498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight10">
      <value value="0.16944104"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="anad-death-multiplierF">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight11">
      <value value="0.14187977"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conflict?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-mate-radius">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baseline" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <exitCondition>year = 100</exitCondition>
    <metric>count males with [anadromous = 1] / count males</metric>
    <metric>count females with [anadromous = 1] / count females</metric>
    <metric>[g] of males</metric>
    <metric>[g] of females</metric>
    <enumeratedValueSet variable="n-trout">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight9">
      <value value="0.2023563"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortalityM">
      <value value="1.0E-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight16">
      <value value="0.05840227"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight17">
      <value value="0.04890256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight18">
      <value value="0.04094807"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight5">
      <value value="0.41163216"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight19">
      <value value="0.03428746"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight6">
      <value value="0.34467609"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight20">
      <value value="0.02871027"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight12">
      <value value="0.11880161"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight7">
      <value value="0.28861109"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight8">
      <value value="0.24166563"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight13">
      <value value="0.09947734"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight14">
      <value value="0.08329636"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight1">
      <value value="0.83734004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prop-parasites">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight15">
      <value value="0.06974738"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight2">
      <value value="0.70113835"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight3">
      <value value="0.58709121"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parasite-load">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="anad-death-multiplierM">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mortalityF">
      <value value="1.0E-5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight4">
      <value value="0.49159498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight10">
      <value value="0.16944104"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="anad-death-multiplierF">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weight11">
      <value value="0.14187977"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conflict?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-mate-radius">
      <value value="5"/>
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
