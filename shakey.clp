; 1. shakey can move in/out of dark rooms, but he cannot move boxes into or out of dark rooms
; 2. light switches have been moved to the hallway since shakey can't move a box to turn them on in a dark room
; 3. lights are on in the goal state, since shakey can't turn them off in the hallway with no boxes
; note: even though there is no use for it in this scenario, there is a working turn-off-lights rule

; templates

(deftemplate shakey-at
   (slot room) ; room or hallway where shakey is at
   (slot on)) ; Whether shakey is on the floor or on a box

(deftemplate light-at
   (slot id) ; light switch number
   (slot room)) ; hallway where the switch is located

(deftemplate light
   (slot id) ; light switch number
   (slot room) ; associated room number
   (slot state)) ; either "on" or "off"

(deftemplate light-goal
   (slot state)) ; true if all lights are ON

(deftemplate box-at
   (slot id)     ; box number
   (slot room))  ; hallway/room the box is in

(deftemplate box-end
   (slot id) ; box number
   (slot room)) ; where the box should end up at

(deftemplate current-box
   (slot id)) ; the box that shakey is focused on

(deftemplate connected
   (slot from)   ; starting location
   (slot to))    ; connected location

(deftemplate previous-location
   (slot room))  ; the last room/hall shakey was in

(deftemplate last-action
   (slot action))  ; the last action performed

(deftemplate goal-state-reached
   (slot state)) ; true if all lights on, boxes in their rooms, shakey in hall 2



; initial state

(deffacts start-state
   (goal-state-reached (state "False"))
   (light-goal (state "False"))

   (shakey-at (room "Hallway1") (on "Floor")) ; "start" function

   (light-at (id "Light1") (room "Hallway2"))
   (light-at (id "Light2") (room "Hallway2"))
   (light-at (id "Light3") (room "Hallway2"))
   (light-at (id "Light4") (room "Hallway2"))
   (light-at (id "Light5") (room "Hallway2"))
   (light-at (id "Light6") (room "Hallway2"))

   (light (id "Light1") (room "Room1") (state "Off"))
   (light (id "Light2") (room "Room2") (state "Off"))
   (light (id "Light3") (room "Room3") (state "Off"))
   (light (id "Light4") (room "Room4") (state "Off"))
   (light (id "Light5") (room "Room5") (state "Off"))
   (light (id "Light6") (room "Room6") (state "Off"))

   (box-at (id "Box1") (room "Hallway2"))
   (box-at (id "Box2") (room "Hallway2"))
   (box-at (id "Box3") (room "Hallway2"))
   (box-at (id "Box4") (room "Hallway2"))
   (box-at (id "Box5") (room "Hallway2"))
   (box-at (id "Box6") (room "Hallway2"))

   (connected (from "Hallway1") (to "Room1"))
   (connected (from "Room1") (to "Hallway1"))

   (connected (from "Hallway1") (to "Room2"))
   (connected (from "Room2") (to "Hallway1"))

   (connected (from "Hallway1") (to "Room3"))
   (connected (from "Room3") (to "Hallway1"))

   (connected (from "Hallway1") (to "Room4"))
   (connected (from "Room4") (to "Hallway1"))

   (connected (from "Hallway2") (to "Room3"))
   (connected (from "Room3") (to "Hallway2"))

   (connected (from "Hallway2") (to "Room4"))
   (connected (from "Room4") (to "Hallway2"))

   (connected (from "Hallway2") (to "Room5"))
   (connected (from "Room5") (to "Hallway2"))

   (connected (from "Hallway2") (to "Room6"))
   (connected (from "Room6") (to "Hallway2"))

   (previous-location (room "None"))
   (last-action (action "None"))
)



; goal state

(deffacts goal-state
   (box-end (id "Box1") (room "Room1"))
   (box-end (id "Box2") (room "Room2"))
   (box-end (id "Box3") (room "Room3"))
   (box-end (id "Box4") (room "Room4"))
   (box-end (id "Box5") (room "Room5"))
   (box-end (id "Box6") (room "Room6"))
   ; includes all lights on, shakey in hall 2, but can't have 2 facts at once
)



; goal checks

(defrule check-lights
   (declare (salience 2))
   (not (light (id ?id) (room ?room) (state "Off")))
   ?shakey <- (shakey-at (room ?current-room) (on ?box-id))
   ?lightsoff <- (light-goal (state "False"))
   =>
   (retract ?lightsoff)
   (assert (light-goal (state "True")))
   (printout t "All lights are on." crlf))

(defrule check-boxes
   (declare (salience 1))
   (not (exists (box-end (id ?box-id) (room ?goal-room))))
   =>
   (printout t "All boxes are in their correct rooms!" crlf))

(defrule check-shakey
   (declare (salience 1))
   (not (exists (box-end (id ?box-id) (room ?goal-room))))
   ?shakey <- (shakey-at (room ?current-room) (on "Floor"))
   ?goal <- (goal-state-reached (state "False"))
   =>
   (if (eq ?current-room "Hallway1") then
      (retract ?shakey)
      (assert (shakey-at (room "Room3") (on "Floor")))
      (printout t "Shakey moves from Hallway1 to Room3." crlf))

   (if (eq ?current-room "Room3") then
      (retract ?shakey)
      (assert (shakey-at (room "Hallway2") (on "Floor")))
      (printout t "Shakey moves from Room3 to Hallway2." crlf))

   (if (eq ?current-room "Room4") then
      (retract ?shakey)
      (assert (shakey-at (room "Hallway2") (on "Floor")))
      (printout t "Shakey moves from Room4 to Hallway2." crlf))

   (if (eq ?current-room "Hallway2") then
   (retract ?goal)
   (assert(goal-state-reached (state "True")))
      (printout t "Shakey has reached Hallway2. Goal state achieved!" crlf))
)



; movement/navigation rules

(defrule climb-up
   ?shakey <- (shakey-at (room ?current-room) (on "Floor"))  
   ?box <- (box-at (id ?box-id) (room ?current-room))  
   ?last <- (last-action (action ?last-action))
   (not (last-action (action "ClimbDown"))) 
   (light (id ?light-id) (room ?goal-room) (state "Off"))
   =>
   (retract ?shakey)
   (assert (shakey-at (room ?current-room) (on ?box-id)))
   (retract ?last)
   (assert (last-action (action "ClimbUp")))  
   (printout t "Shakey climbs up on " ?box-id " in " ?current-room crlf))

(defrule climb-down
   ?shakey <- (shakey-at (room ?current-room) (on ?box-id))  
   (test (neq ?box-id "Floor"))  
   (not (last-action (action "ClimbUp")))
   =>
   (retract ?shakey)
   (assert (shakey-at (room ?current-room) (on "Floor")))
   (printout t "Shakey climbs down from " ?box-id " to Floor in " ?current-room crlf))

(defrule turn-on-light
   (shakey-at (room ?current-room) (on ?box-id))
   (box-at (id ?box-id) (room ?current-room))
   (light-at (id ?light-id) (room ?current-room))
   ?light <- (light (id ?light-id) (room ?room) (state "Off"))
   ?last <- (last-action (action ?last-action))
   (not (last-action (action "TurnOffLight")))
   =>
   (retract ?light)
   (assert (light (id ?light-id) (room ?room) (state "On")))
   (retract ?last)
   (assert (last-action (action "TurnOnLight")))
   (printout t "Shakey turns on " ?light-id " in " ?current-room ". " ?room " is lit up " crlf))

(defrule turn-off-light
   (shakey-at (room ?current-room) (on ?box-id))
   (box-at (id ?box-id) (room ?current-room))
   (light-at (id ?light-id) (room ?current-room))
   ?light <- (light (id ?light-id) (room ?room) (state "On"))
   ?last <- (last-action (action ?last-action))
   (not (last-action (action "TurnOnLight"))) 
   =>
   (retract ?light)
   (assert (light (id ?light-id) (room ?room) (state "Off")))
   (retract ?last)
   (assert (last-action (action "TurnOffLight")))
   (printout t "Shakey turns off " ?light-id " in " ?current-room ". " ?room " is dark again " crlf))

(defrule push-box
   (declare (salience 2))
   ?shakey <- (shakey-at (room ?current-room) (on "Floor"))
   ?box <- (box-at (id ?box-id) (room ?current-room))
   ?goal <- (box-end (id ?box-id) (room ?goal-room))
   ?current <- (current-box (id ?box-id ))
   (connected (from ?current-room) (to ?goal-room))
   ?last <- (last-action (action ?last-action))
   (light (id ?light-id) (room ?goal-room) (state "On"))
   =>
   (retract ?box)
   (assert (box-at (id ?box-id) (room ?goal-room)))
   (retract ?goal)
   (retract ?current)
   (retract ?shakey)
   (assert (shakey-at (room ?goal-room) (on "Floor")))
   (retract ?last)
   (assert(last-action (action "PushBox")))
   (printout t "Shakey pushes " ?box-id " from " ?current-room " to " ?goal-room crlf))

(defrule select-box ; set a goal for shakey to focus on one at a time
   (declare (salience 10))
   (not (exists (current-box)))
   ?goal <- (box-end (id ?box-id) (room ?room))  
   =>
   (assert (current-box (id ?box-id)))
   (printout t "Shakey wants to move " ?box-id " to " ?room crlf))

(defrule move-shakey
   ?shakey <- (shakey-at (room ?current-room) (on "Floor"))
   ?prev <- (previous-location (room ?old-room))
   (connected (from ?current-room) (to ?next-room)) 
   (not (previous-location (room ?next-room)))  ; prevent infinite loops
   (not (goal-state-reached (state "True"))) ; stop moving after going to hallway 2 goal
   =>
   (retract ?prev)
   (assert (previous-location (room ?current-room)))
   (retract ?shakey)
   (assert (shakey-at (room ?next-room) (on "Floor")))
   (printout t "Shakey moves from " ?current-room " to " ?next-room crlf))


; if shakey is currently moving a box whose room is in the opposite hall:

(defrule move-to-transition-room ; transition rooms are room 3 and 4, they connect hallways 1 and 2
   (declare (salience 2))
   ?shakey <- (shakey-at (room ?current-hallway) (on "Floor"))  
   ?current-box <- (current-box (id ?box-id))  
   ?goal <- (box-end (id ?box-id) (room ?goal-room))  
   ?box <- (box-at (id ?box-id) (room ?current-hallway))  
   (or (test (eq ?current-hallway "Hallway1"))
       (test (eq ?current-hallway "Hallway2")))
   (not (connected (from ?current-hallway) (to ?goal-room)))
   =>
   (retract ?shakey)
   (retract ?box)

   (if (eq ?current-hallway "Hallway1") then
      (assert (shakey-at (room "Room3") (on "Floor")))
      (assert (box-at (id ?box-id) (room "Room3")))
      (printout t "Shakey pushes " ?box-id " from Hallway1 to Room3" crlf))

   else
      (assert (shakey-at (room "Room4") (on "Floor")))
      (assert (box-at (id ?box-id) (room "Room4")))
      (printout t "Shakey pushes " ?box-id " from Hallway2 to Room4" crlf))

(defrule move-to-opposite-hallway
   ?shakey <- (shakey-at (room ?current-room) (on "Floor"))  
   ?box <- (box-at (id ?box-id) (room ?current-room))  
   (or (test (eq ?current-room "Room3"))
       (test (eq ?current-room "Room4")))
   =>
   (retract ?shakey)
   (retract ?box)

   (if (eq ?current-room "Room3") then
      (assert (shakey-at (room "Hallway2") (on "Floor")))
      (assert (box-at (id ?box-id) (room "Hallway2")))
      (printout t "Shakey pushes " ?box-id " from Room3 to Hallway2" crlf))

   else
      (assert (shakey-at (room "Hallway1") (on "Floor")))
      (assert (box-at (id ?box-id) (room "Hallway1")))
      (printout t "Shakey pushes " ?box-id " from Room4 to Hallway1" crlf))

