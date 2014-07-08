

grp = display.newGroup()
grp.x, grp.y = 160,240

square = display.newRect(grp,-80,-140,60,60)
transition.to(grp,{ time = 10000, rotation = 3600 })