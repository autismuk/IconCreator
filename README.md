IconCreator
===========

This program is designed to manage the increasingly absurd number of Icon files that Android apps, and especially Apple apps ask for.

It is a lua script (so it requires the command line lua). It requires, besides the script, one other file - an SVG of the icon (e.g. Vector Graphics format) and leverages the open source program "Inkscape" to create icons of all the required sizes from it.

It should not be necessary to use Inkscape to create the SVG the icon is based on, most packages will generate SVG format.

The program is run from the command line and has three optional parameters

-d delete icon files
-a Android files
-i iDevice (Apple) files

so, for example 

lua iconcreator.lua -a -i will generate all icon files for Android and Apple builds
lua iconcreator.lua -a -d will delete all android icon files

The image itself needs to be called 'icon.svg'.

Apart from the autoscaling (cleaner than scaling a bitmap graphic) it removes clutter in your application directory.

It was written for OSX, so I have not tested it on Linux or Windows (though I know the inkscape conversion works on both). A small change will be needed for Linux or Windows, to change the full path to the Inkscape binary. I have suggested likely file names, if anyone uses this and gets a working file name please let me know and I will add them.

It's all free of course.
