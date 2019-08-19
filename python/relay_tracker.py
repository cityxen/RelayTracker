################################################################
# Relay Tracker (Python version)
# 
# v1.0
# By Deadline
#
# 2019 CityXen
#
# Required:
# pip3 install keyboard
#
################################################################
"""
import sys, pygame
pygame.init()

size = width, height = 320, 240
speed = [2, 2]
black = 0, 0, 0

screen = pygame.display.set_mode(size)

ball = pygame.image.load("characters.png")
ballrect = ball.get_rect()

while 1:
    for event in pygame.event.get():
        if event.type == pygame.QUIT: sys.exit()

    ballrect = ballrect.move(speed)
    if ballrect.left < 0 or ballrect.right > width:
        speed[0] = -speed[0]
    if ballrect.top < 0 or ballrect.bottom > height:
        speed[1] = -speed[1]

    screen.fill(black)
    screen.blit(ball, ballrect)
    pygame.display.flip()

"""
import keyboard
import time
import serial

from graphics import *
win = GraphWin("Relay Tracker",600,400)

relayTrackerImage = Image(Point(300,200),"relayTracker.gif")
relayTrackerImage.draw(win)

while True:
    time.sleep(.05)

    p1 = win.getMouse()
    p1.draw(win)
    
    try:
        if keyboard.is_pressed('q'):
            print('You pressed q')
            break
        else:
            pass
    except:
        break

