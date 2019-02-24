#!/usr/bin/env sh
if [ ! -n $* ]
then
    vala vpg.vala --save-temps --pkg gio-2.0 --pkg template-glib-1.0 --run-args $*
else
    vala vpg.vala --save-temps --pkg gio-2.0 --pkg template-glib-1.0
fi
