#!/usr/bin/python3

import numpy as np
import scipy
import scipy.ndimage
import math

in_img = 255 - scipy.ndimage.imread("in.png", flatten=False)


out_img = in_img.copy()
out_img.fill(0)
out_img[:,:,0].fill(255)
out_diagonals = out_img.copy()

# Road width in pixel
width = 5

def grow(ii,jj):
    # Let's remember:
    # double ii,jj is the main current pixel
    # single i,j is the pixel around the current pixel

    for i in range(ii-width, ii+width):
        for j in range(jj-width, jj+width):
            dx = ii - i
            dy = jj - j
            distance = int(math.sqrt(pow(dx, 2) + pow(dy, 2)))
            
            if distance < width:
                distance = distance * 255 / width
                if distance < out_img[i][j][0]:
                    out_img[i][j][0] = distance

                    # Find direction
                    angle = math.atan2(dy, dx)
                    iangle = int(angle / math.pi / 2 * 255 + 128)
                    if(iangle < 0):
                        print(iangle)
                    out_img[i][j][1] = iangle
                    
                    

for i in range(width, out_img.shape[0] - width):
    for j in range(width, out_img.shape[1] - width):
        pixel = in_img[i,j]

        if sum(pixel) > 20 * 3:
            grow(i,j)

# set alpha to 1
out_img[:,:,3] = 255
        
scipy.misc.imsave("out.png", out_img)
