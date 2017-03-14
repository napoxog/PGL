#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    package require Tk
    switch $tcl_platform(platform) {
	windows {
            option add *Button.padY 0
	}
	default {
            option add *Scrollbar.width 10
            option add *Scrollbar.highlightThickness 0
            option add *Scrollbar.elementBorderWidth 2
            option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v1.60 Project
#




#############################################################################
## vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
#############################################################################
## Procedure:  vTcl:rename

proc ::vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

#############################################################################
## Procedure:  vTcl:image:create_new_image

proc ::vTcl:image:create_new_image {filename {description {no description}} {type {}} {data {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    # Does the image already exist?
    if {[info exists ::vTcl(images,files)]} {
        if {[lsearch -exact $::vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists ::vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            ## will add 'broken image' again when img is fixed, for now create empty
            set object [image create photo -width 1 -height 1]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]
    set ::vTcl(images,$reference,image)       $object
    set ::vTcl(images,$reference,description) $description
    set ::vTcl(images,$reference,type)        $type
    set ::vTcl(images,filename,$object)       $filename

    lappend ::vTcl(images,files) $filename
    lappend ::vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

#############################################################################
## Procedure:  vTcl:image:get_image

proc ::vTcl:image:get_image {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

#############################################################################
## Procedure:  vTcl:image:get_creation_type

proc ::vTcl:image:get_creation_type {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif    {return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

foreach img {


            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

}
#############################################################################
## vTcl Code to Load User Images

catch {package require Img}

foreach img {

        {{[file join PGL.gif]} {user image} user {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

#############################################################################
# vTcl Code to Load Stock Fonts


if {![info exist vTcl(sourcing)]} {
set vTcl(fonts,counter) 0
#############################################################################
## Procedure:  vTcl:font:add_font

proc ::vTcl:font:add_font {font_descr font_type {newkey {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[info exists ::vTcl(fonts,$font_descr,object)]} {
        ## cool, it already exists
        return $::vTcl(fonts,$font_descr,object)
    }

     incr ::vTcl(fonts,counter)
     set newfont [eval font create $font_descr]
     lappend ::vTcl(fonts,objects) $newfont

     ## each font has its unique key so that when a project is
     ## reloaded, the key is used to find the font description
     if {$newkey == ""} {
          set newkey vTcl:font$::vTcl(fonts,counter)

          ## let's find an unused font key
          while {[vTcl:font:get_font $newkey] != ""} {
             incr ::vTcl(fonts,counter)
             set newkey vTcl:font$::vTcl(fonts,counter)
          }
     }

     set ::vTcl(fonts,$newfont,type)       $font_type
     set ::vTcl(fonts,$newfont,key)        $newkey
     set ::vTcl(fonts,$newfont,font_descr) $font_descr
     set ::vTcl(fonts,$font_descr,object)  $newfont
     set ::vTcl(fonts,$newkey,object)      $newfont

     lappend ::vTcl(fonts,$font_type) $newfont

     ## in case caller needs it
     return $newfont
}

#############################################################################
## Procedure:  vTcl:font:getFontFromDescr

proc ::vTcl:font:getFontFromDescr {font_descr} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[info exists ::vTcl(fonts,$font_descr,object)]} {
        return $::vTcl(fonts,$font_descr,object)
    } else {
        return ""
    }
}

vTcl:font:add_font \
    "-family helvetica -size 12" \
    stock \
    vTcl:font1
vTcl:font:add_font \
    "-family courier -size 12" \
    stock \
    vTcl:font3
vTcl:font:add_font \
    "-family helvetica -size 12 -weight bold" \
    stock \
    vTcl:font5
vTcl:font:add_font \
    "-family lucida -size 18" \
    stock \
    vTcl:font8
}
#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists} {
                wm deiconify $newname
            } elseif {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[winfo exists $newname] && [wm state $newname] == "normal"} {
                vTcl:FireEvent $newname <<Show>>
            }
        }
        hide    {
            if {$exists} {
                wm withdraw $newname
                vTcl:FireEvent $newname <<Hide>>
                return}
        }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
        interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
        set widget($top_or_alias,$alias) $target
        if {$cmdalias} {
            interp alias {} $top_or_alias.$alias {} $widgetProc $target
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                foreach rep "\{%W $target\} $params" {
                    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
                }
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    ## break exception, stop processing
                    set stop_processing 1
                } elseif {$result != 0} {
                    bgerror $errortext
                }
                break
            }
        }
        if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top43
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab43 {
        array set save {-activeforeground 1 -background 1 -disabledforeground 1 -foreground 1 -height 1 -highlightcolor 1 -image 1 -text 1 -underline 1 -width 1}
    }
    namespace eval ::widgets::$base.lab47 {
        array set save {-activebackground 1 -background 1 -borderwidth 1 -disabledforeground 1 -font 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$base.but44 {
        array set save {-_tooltip 1 -borderwidth 1 -command 1 -disabledforeground 1 -font 1 -text 1}
    }
    namespace eval ::widgets::$base.but48 {
        array set save {-_tooltip 1 -borderwidth 1 -command 1 -disabledforeground 1 -font 1 -text 1}
    }
    namespace eval ::widgets::$base.but45 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -font 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$base.che44 {
        array set save {-_tooltip 1 -activebackground 1 -background 1 -borderwidth 1 -disabledforeground 1 -font 1 -highlightthickness 1 -selectcolor 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.men49 {
        array set save {-_tooltip 1 -borderwidth 1 -disabledforeground 1 -font 1 -indicatoron 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.men49.m {
        array set save {-disabledforeground 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$base.but43 {
        array set save {-_tooltip 1 -borderwidth 1 -command 1 -disabledforeground 1 -font 1 -text 1}
    }
    set base .top44
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 0
    }
    namespace eval ::widgets::$base.fra53 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra53
    namespace eval ::widgets::$site_3_0.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra83
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-_tooltip 1 -command 1 -disabledforeground 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledforeground 1 -exportselection 1 -font 1 -height 1 -listvariable 1 -width 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::$site_3_0.but58 {
        array set save {-borderwidth 1 -command 1 -default 1 -disabledforeground 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but59 {
        array set save {-_tooltip 1 -borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent44 {
        array set save {-background 1 -disabledforeground 1 -insertbackground 1 -textvariable 1 -validate 1 -validatecommand 1}
    }
    namespace eval ::widgets::$site_3_0.lab45 {
        array set save {-disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$base.fra54 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra54
    namespace eval ::widgets::$site_3_0.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra74
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra48 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra48
    namespace eval ::widgets::$site_5_0.lab45 {
        array set save {-disabledforeground 1 -font 1 -height 1 -justify 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but49 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but50 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab52 {
        array set save {-disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent53 {
        array set save {-_tooltip 1 -background 1 -disabledforeground 1 -exportselection 1 -insertbackground 1 -textvariable 1 -validate 1}
    }
    namespace eval ::widgets::$site_5_0.lab44 {
        array set save {-disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.scr81 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_4_0.lis75 {
        array set save {-background 1 -disabledforeground 1 -exportselection 1 -font 1 -height 1 -listvariable 1 -selectmode 1 -takefocus 1 -width 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::$site_3_0.fra44 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra44
    namespace eval ::widgets::$site_4_0.cpd45 {
        array set save {-disabledforeground 1 -height 1 -justify 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.scr47 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_4_0.lis46 {
        array set save {-_tooltip 1 -background 1 -disabledforeground 1 -font 1 -listvariable 1 -selectmode 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::$site_4_0.but43 {
        array set save {-_tooltip 1 -borderwidth 1 -command 1 -disabledforeground 1 -justify 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.scr45 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_4_0.fra44 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra44
    namespace eval ::widgets::$site_5_0.lab45 {
        array set save {-disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.men46 {
        array set save {-borderwidth 1 -disabledforeground 1 -indicatoron 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.men46.m {
        array set save {-disabledforeground 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_4_0.lis44 {
        array set save {-background 1 -disabledforeground 1 -exportselection 1 -font 1 -height 1 -listvariable 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::$site_3_0.but62 {
        array set save {-_tooltip 1 -borderwidth 1 -command 1 -disabledforeground 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but63 {
        array set save {-_tooltip 1 -borderwidth 1 -command 1 -disabledforeground 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but67 {
        array set save {-_tooltip 1 -borderwidth 1 -command 1 -disabledforeground 1 -state 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -state 1 -text 1}
    }
    set base .top55
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 0
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.lab96 {
        array set save {-disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$base.but44 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$base.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra88
    namespace eval ::widgets::$site_3_0.but91 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but89 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$base.lis84 {
        array set save {-background 1 -borderwidth 1 -disabledforeground 1 -exportselection 1 -font 1 -listvariable 1 -selectmode 1}
    }
    namespace eval ::widgets::$base.lab87 {
        array set save {-disabledforeground 1 -text 1}
    }
    namespace eval ::widgets::$base.lab48 {
        array set save {-borderwidth 1 -disabledforeground 1 -relief 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            pgenv
            select_ver
            is_admin
            run_as_admin
            run_as
            run_as_dbadmin
            get_pns_path
            get_pns_host
            run_as_user
            check_bin_set_sens
            set_admin_sens
            get_pns_ver
            get_app_ver
            show_lpm
            set_list_sel
            get_remote_cmd_result
            get_remote_cmd_result_as
            daemon_op
            add_lpm_item
            show_licsync
            set_list_Feat_sel
            set_list_Serv_sel
            save_feat_file
            set_ent_Search
            set_ent_AddSrv
            set_list_Log_sel
            set_list_LogDate_sel
            select_LogFilter
            set_log_lists
            save_last_ver
            set_list_Feat_click
            load_config
            check_scan_paths
            get_Feat_desc
            resize_bkg
            resize_photo
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {
global PGL_version
global PGL_date
global Epos_Ver 
global Epos_Path 
global vers
global paths
global fileName 
global ver_lines

global PGLconf
global PGLconf_vers
global PGLconf_geom

bind .top43 <<DeleteWindow>> {save_last_ver;exit}
bind .top43 <Configure> { set PGLconf_geom [wm geometry .top43];}

#
###restore main window size and position
if { [string length $PGLconf_geom] } { wm geometry .top43 $PGLconf_geom } {set PGLconf_geom [wm geometry .top43]}


.top43.lab43.men44.m delete 0 end

set def_ver 0
set vers {}
set paths {}
#Menubutton2 configure -text "admin"
Label2 configure -text "Selected Software version:\n(to select version click there ->)"
.top43.lab47 configure -text "Created by Alexey Gritsenko (alexey.gritsenko@pdgm.com)\nParadigm Russia & CIS\nVersion: $PGL_version \($PGL_date\) (unsupported)"
set App_Caption "Paradigm Software Launcher ($::env(USER)@$::env(HOST))"
wm title .top43 "$App_Caption"
wm protocol .top43 WM_WINDOW_DELETE exit
foreach ver_line  $ver_lines {
#               regexp {^[ \t]*([^#]\S*)[\t ]+(/\S*)[\t ]*(.*)} $ver_line -> ver path comm ]
    set nmatch [ regexp {^[ \t]*([^#]\S*)[\t ]+(/\S*)[\t ]*(.*)} $ver_line -> ver path comm ]
#    puts "matches $nmatch"
    if { $nmatch } {
        set ver [ string trim $ver ]
	set path [ string trim $path ]
        set comm [ string trim $comm ]
        if { [ regexp {^#(.*)}  $comm -> comm2] } {
    	    set comm [string trim $comm2]
        }
        #puts "Ver:\"$ver\"\t\tPath:\"$path\"\t\t Comm:\"$comm\""
        #set ver "Paradigm $comm"
        # make lists
        if { [string length [string trim $comm]] < 1 } {
        set comm $ver
        }
        if { [ file exists $path] == 1 } {
        lappend vers ${comm}
        lappend paths ${path}
        set ver_id [expr [llength $vers] - 1 ]
        .top43.lab43.men44.m add command -label ${comm} -command " select_ver $ver_id "
        # check for test release
        if { ( [regexp -nocase {.*TEST.*} $comm ] == 0 ) } {
            set def_ver [ expr [llength $vers]-1 ]
        }
        } else {
        puts "Warning: Version $comm has non-existing path ($path)"
        }
    } 
}
foreach ver $vers {
        if { [string equal $PGLconf_vers $ver ] } { set def_ver [ expr [lsearch $vers $ver] ] } 
}
puts "Last_VER: \[$PGLconf_vers\]"
puts "Versions file loaded ([llength $vers])"
select_ver $def_ver
}
#############################################################################
## Procedure:  pgenv

proc ::pgenv {} {
global Epos_Path
global cmd_env
global PNS_host
global Epos_arch_Path

#/bin/sh -c "export PG_PROJECTS=$HOME/Geolog;export PG_UNIT_SYSTEM=metric;export PNS_HOST=kraft42;export LM_LICENSE_FILE=7507@yptmos1;/apps/EPOS4/Final/geolog6.7.1/bin/geolog6"
#/bin/sh -c "export PG_PROJECTS=$HOME/Geolog;export PG_UNIT_SYSTEM=metric;export PNS_HOST=pcmos1;export LM_LICENSE_FILE=7507@yptmos1;/apps/PDGM/Paradigm-2011.2/Applications/bin/geolog6"
set ::env(PG_ROOT) $Epos_Path
set cmd_env "setenv PG_ROOT $Epos_Path;setenv PATH $Epos_Path/bin:\$PATH; setenv PG_GOCAD_PATH $Epos_Path/Modeling"
catch { exec csh -c "$cmd_env ; pgarch" } arch_path_
set arch_path "$Epos_Path/arch/$arch_path_"
if { [ file exists $arch_path ] == 1 } {
    set Epos_arch_Path $arch_path
}
puts "ARCH_PATH: $arch_path_"
set ::env(PG_ARCH_ROOT) "$Epos_Path/arch/$arch_path_"
set ::env(LD_LIBRARY_PATH) "$Epos_Path/arch/$arch_path_/lib"

#puts "$::env(PG_ROOT)"
#puts "$::env(PG_ARCH_ROOT)"
puts "$::env(LD_LIBRARY_PATH)"
#exec env | grep /apps
}
#############################################################################
## Procedure:  select_ver

proc ::select_ver {index} {
global vers
global paths
global Epos_Ver
global Epos_Path
global PNS_dir
global PNS_host
global PNS_ver
global APP_ver

global G_PNS_host
set G_PNS_host ""

set Epos_Ver [lindex $vers $index]  
set Epos_Path [lindex $paths $index]  

set PNS_host [get_pns_host]
puts "Sel_PNS: $PNS_host"
if { ![string equal "undefined" $PNS_host] } {
    set PNS_dir [get_pns_path $PNS_host]
    set PNS_ver [get_pns_ver $PNS_dir]
} else {
    set PNS_dir $PNS_host
    set PNS_ver $PNS_host
}
set APP_ver [get_app_ver $Epos_Path]
puts "Info: Selected version is $Epos_Ver ($Epos_Path) ($APP_ver)"
puts "PNS: $PNS_host @ $PNS_dir ($PNS_ver)"
#if { [string length $APP_ver] && [string length $PNS_ver] && ![string equal $APP_ver $PNS_ver] } {
#catch { tk_messageBox -parent .top43 -icon warning -type yesno -title "Paradigm Software Launcher" -message "Current PNS has incompatible version!\nApplications version: $APP_ver\nPNS version: $PNS_ver\n\nStart local PNS manager?" } ans
#if { [ string equal $ans "yes"] } {show_lpm}
#}

global APF_xml_list
global Epos_Path
set APF_xml_list {}
set APF_xml_fn $Epos_Path/util/xml/pg_product_catalog.xml
if { [ file exist $APF_xml_fn ] } {
    catch {set v_file [open $APF_xml_fn r]} openres
    if { [regexp {^file[0123456789]*} $openres ] } {
        set contents [read -nonewline $v_file] 
        set APF_xml_list [split $contents "\n"]
        close $v_file 
    }
}

set_admin_sens


.top43.lab43.men44 configure -text "$Epos_Ver @ $PNS_host"
}
#############################################################################
## Procedure:  is_admin

proc ::is_admin {} {
global fileName

catch {set v_file [open $fileName "r+"]} openres
if { [regexp {^file[0123456789]*} $openres ] } {
close $v_file
return 1
catch { exec gedit $fileName }
} else {
return 0
} 
}
#############################################################################
## Procedure:  run_as_admin

proc ::run_as_admin {cmd} {
global widget
pgenv
global cmd_env
global PNS_dir
global PNS_host
global fileName
global Epos_Path

set pns_host $PNS_host
set pns_path $PNS_dir

if { [string equal $pns_host "undefined" ] } {
if { [ file exist $fileName ] } {
set dbadmin [file attributes $fileName -owner ]
} else {
set dbadmin [file attributes [file dirname $::argv0] -owner ]
}
set run_as_admin [run_as $dbadmin $cmd]
return
}
# check for Epos3 - to does not have query_eposdb key
if { [file exist $PNS_dir/pns_config ] } {
catch { exec /bin/csh -c "$PNS_dir/pns_utility MIN_FEEDBACK = none UTL_CMD = query_eposadm UTL_HOST = $pns_host" } dbadmin
} else {
set dbadmin [file attributes $fileName -owner ]
}
puts "PGadmin: $dbadmin"

set run_as_admin [run_as $dbadmin $cmd]
}
#############################################################################
## Procedure:  run_as

proc ::run_as {asuser cmd} {
global widget
pgenv
global cmd_env
global Use_Shell
global PNS_host
global Epos_Ver

#check for Debug switch
if { $Use_Shell } {
    set Cap_cmd "$Epos_Ver ([string range $cmd [expr [string last "/" $cmd]+1] end ])"
    #setenv PG_ARG_log_level DEBUG;
    append cmd_env ";setenv PG_ARG_log_level DEBUG;setenv PG_DEBUG yes"
    #catch { exec xterm -sl 10240 -hold -geom 300x80 -T "$Cap" -n "$Cap" -e "$cmd_env;setenv PG_ARG_log_level DEBUG;setenv PG_DEBUG yes;$cmd" & } result
} else {
    set Cap_cmd [string range $cmd [expr [string last "/" $cmd]+1] end ]
}
set Cap "Run $Cap_cmd as $asuser..."

#check if dbepos user is the same as current... If so - do not ask for password
catch { exec /bin/csh -c "env | grep USER" } test
regexp {USER=(\S*)} $test -> cuser
puts "Current: $cuser"

set xterm_opt [concat -T '$Cap' -n '$Cap']
puts "xtermopts: $xterm_opt"
puts "ENV: $cmd_env"
puts "CMD: $cmd"
set same_user [string equal $cuser $asuser ]
if { $same_user && !$Use_Shell } {
    puts "Running csh..."
    catch { exec /bin/csh -c "$cmd_env;$cmd"  } result
    puts "RES: $result"
} else {
    if { $Use_Shell } {
        append xterm_opt " -hold -sl 10240 -hold -geom 300x80 "
    } 
    puts "Running Xterm...Debug=$Use_Shell"
    if { $same_user } {
        set cmd_ [concat xhost + && xterm $xterm_opt -e "'$cmd_env;$cmd;sleep 1'" ]
    } else {
        set cmd_ [concat xhost + && xterm $xterm_opt -e "su $asuser -c '$cmd_env;$cmd;sleep 1'" ]
    }
    puts "CMD_: $cmd_"
    catch { exec /bin/csh -c $cmd_  } result
    puts "RES: $result"
}
set run_as $result
}
#############################################################################
## Procedure:  run_as_dbadmin

proc ::run_as_dbadmin {cmd} {
global widget
pgenv
global cmd_env
global PNS_dir
global PNS_host
global fileName
global Epos_Path

set pns_host $PNS_host
set pns_path $PNS_dir

if { [string equal $pns_host "undefined" ] } {
set dbadmin [file attributes $fileName -owner ]
set run_as_dbadmin [run_as $dbadmin $cmd ]
return
}
# check for Epos3 - to does not have query_eposdb key
if { [file exist $PNS_dir/pns_config ] } {
catch { exec /bin/csh -c "$PNS_dir/pns_utility MIN_FEEDBACK = none UTL_CMD = query_eposdb UTL_HOST = $pns_host" } dbadmin
} else {
set dbadmin [file attributes $fileName -owner ]
}
puts "DBadmin: $dbadmin"

set run_as_dbadmin [run_as $dbadmin $cmd ]
return
}
#############################################################################
## Procedure:  get_pns_path

proc ::get_pns_path {pns_host} {
global widget
global Epos_Path
pgenv

if { [string length $pns_host] < 1 } {
set pns_host [get_pns_host]
}

if { [string equal $pns_host "undefined" ] } {
return
}
#puts "PNS: $pns_host"
set from_ "uplevel dir (default)"
# get default uplevel dir PNS path
    set Epos_sub [string range $Epos_Path 0 [expr [string last "/" $Epos_Path] -1] ]
    if {  [file exist "$Epos_sub/PNS3TE/bin" ] } {
        set PNS_dir "$Epos_sub/PNS3TE/bin"
    } elseif { [file exist "$Epos_sub/PNS4/bin" ] } {
        set PNS_dir "$Epos_sub/PNS4/bin"
    } elseif { [file exist "$Epos_sub/PNS41/bin" ] } {
        set PNS_dir "$Epos_sub/PNS41/bin"
    } elseif { [file exist "$Epos_sub/Services/bin" ] } {
        set PNS_dir "$Epos_sub/Services/bin"
    } else {set PNS_dir "undefined"}
# get PNS_HOST's running PNS path
        set cmd [concat ps -do cmd | grep pns_server | grep -v grep]
        puts "CMD: $cmd"
        set error_ssh [get_remote_cmd_result $pns_host $cmd]
        puts "SSH: $error_ssh"
        set path_pos [string first "/arch/" $error_ssh  ]
        puts "POS: $path_pos"
        if { $path_pos > 0 } {
            set PNS_run_dir [string range $error_ssh 0 $path_pos ]bin
            puts "DIR: $PNS_run_dir"
            if { [file exist $PNS_run_dir ] } {
                puts "PNS_DIR: get from running binary path"
                #set get_pns_path $PNS_run_dir
                #return $PNS_run_dir
                puts "DIR_run: $PNS_run_dir"
            }
        } else {set PNS_run_dir "undefined"}
puts "PNS_dir:     $PNS_dir"
puts "PNS_run_dir: $PNS_run_dir"   
# check if PNS in default path is installed but not running...
        if { [file exist $PNS_dir/pns_install_service] && [string equal $PNS_run_dir "undefined"]} {
	    catch { tk_messageBox -parent .top43 -icon warning -title "Paradigm Software Launcher" -type yesno -message "PNS is installed on '$pns_host' but is not running...\n\nInstall \& start PNS service?\n\nROOT password required" } answer
            if { [string equal "yes" $answer] } {
    		set cmd_ [concat echo -e "\n\n" | $PNS_dir/pns_install_service]
    	        set result [get_remote_cmd_result_as root $pns_host $cmd_]
        	puts "RES: $result"
    	    }
    	} 
# check if running PNS version is compatible with selected applications...
    if { ![string equal $PNS_run_dir "undefined"] } {
	set PNS_ver [get_pns_ver $PNS_run_dir]
	set APP_ver [get_app_ver $Epos_Path]
	puts "APP_sel: ($Epos_Path) ($APP_ver)"
	puts "PNS_run: $pns_host @ $PNS_run_dir ($PNS_ver)"
	if { [string length $APP_ver] && [string length $PNS_ver] && ![string equal $APP_ver $PNS_ver] } {
	    catch { tk_messageBox -parent .top43 -icon warning -type yesno -title "Paradigm Software Launcher" -message "Currently running PNS has incompatible version!\nApplications version: $APP_ver\nPNS version: $PNS_ver\n\nOpen PNS manager?" } ans
	    if { [ string equal $ans "yes"] } {
		puts "PNS_dir for LPM: $PNS_dir"
		set ::PNS_dir $PNS_dir
		show_lpm
	    }
	}
    } elseif { [string equal $PNS_dir "undefined" ] } {
	    catch { tk_messageBox -parent .top43 -icon warning -type yesno -title "Paradigm Software Launcher" -message "No running or installed PNS detected on \<$pns_host\>!\n\nOpen PNS manager?" } ans
	    if { [ string equal $ans "yes"] } {
		puts "PNS_dir for LPM: $PNS_dir"
		set ::PNS_dir $PNS_dir
		show_lpm
	    }
    }
# check if PNS is not found in default location but PNS is running on the server...
    if { [string equal $PNS_dir "undefined"] && ![string equal $PNS_run_dir "undefined"] } {
	set PNS_dir $PNS_run_dir
    }
puts "PNS_DIR: get from uplevel dir - $PNS_dir"
set get_pns_path $PNS_dir
return $PNS_dir

 
# OLD priority here 
# get PNS_HOST's running PNS path
set cmd [concat ps -do cmd | grep pns_server | grep -v grep]
puts "CMD: $cmd"
set error_ssh [get_remote_cmd_result $pns_host $cmd]
puts "SSH: $error_ssh"
set path_pos [string first "/arch/" $error_ssh  ]
puts "POS: $path_pos"
if { $path_pos > 0 } {
    set PNS_dir [string range $error_ssh 0 $path_pos ]bin
    puts "DIR: $PNS_dir"
    if { [file exist $PNS_dir ] } {
        set get_pns_path $PNS_dir
        return $PNS_dir
    }
} else {
# get default uplevel dir PNS path
    set Epos_sub [string range $Epos_Path 0 [expr [string last "/" $Epos_Path] -1] ]
    if {  [file exist "$Epos_sub/PNS3TE/bin" ] } {
        set PNS_dir "$Epos_sub/PNS3TE/bin"
    } elseif { [file exist "$Epos_sub/PNS4/bin" ] } {
        set PNS_dir "$Epos_sub/PNS4/bin"
    } elseif { [file exist "$Epos_sub/PNS41/bin" ] } {
        set PNS_dir "$Epos_sub/PNS41/bin"
    } elseif { [file exist "$Epos_sub/Services/bin" ] } {
        set PNS_dir "$Epos_sub/Services/bin"
    } else {
    set PNS_dir "undefined"
    #tk_messageBox -parent .top43 -icon error -title "Paradigm Software Launcher" -message "Unable to detect Services path!" 
    }
    puts "DIR: $PNS_dir"
    if { [file exist $PNS_dir/pns_install_service] } {
        catch { tk_messageBox -parent .top43 -icon warning -title "Paradigm Software Launcher" -type yesno -message "PNS is installed on '$pns_host' but is not running...\n\nInstall \& start PNS service?\n\nROOT password required" } answer
        if { [string equal "yes" $answer] } {
            set cmd_ [concat echo -e "\n\n" | $PNS_dir/pns_install_service]
            set result [get_remote_cmd_result_as root $pns_host $cmd_]
            puts "RES: $result"
        }
    }
}
set get_pns_path $PNS_dir
return $PNS_dir
#puts $PNS_dir
}
#############################################################################
## Procedure:  get_pns_host

proc ::get_pns_host {} {
global widget

pgenv
global cmd_env
global PNS_dir
global fileName
global Epos_Path
global G_PNS_host
global local_host
global Epos_binary

set Epos_binary ""
puts "GET_PNS: <[array names env PNS_HOST ]> : <[string length $G_PNS_host]> : "
if { [file exist $Epos_Path/bin/pg3] } {
    catch { exec /bin/csh -c "$cmd_env;pg3 -s && cat ~/Epos3_env* | grep PNS_HOST | grep -v hostname | awk '{print \"PNS_HOST=\"\$NF}'" } pgres
    set Epos_binary "pg3"
} elseif { [file exist $Epos_Path/bin/pg4] } {
    catch { exec /bin/csh -c "$cmd_env;pg4 -cmd=env | grep PNS_HOST" } pgres
    set Epos_binary "pg4"
} elseif { [file exist $Epos_Path/bin/pg41] } {
    catch { exec /bin/csh -c "$cmd_env;pg41 -cmd=env | grep PNS_HOST" } pgres
    set Epos_binary "pg41"
} elseif { [file exist $Epos_Path/bin/pgstart] } {
    catch { exec /bin/csh -c "$cmd_env;pgstart -cmd=env | grep PNS_HOST" } pgres
    set Epos_binary "pgstart"
} elseif { [array names env PNS_HOST ] != "" } {
    set pgres PNS_HOST=$g_pns
} elseif { [string length $G_PNS_host] } {
    set pgres PNS_HOST=$G_PNS_host
} elseif { [file exist $Epos_Path/../site/bin/geolog6_env.tcl] } {
#[array names env PNS_HOST ] == "" &&  ![string length G_PNS_host]  && 
    catch { exec /bin/csh -c "$cmd_env;grep PNS_HOST $Epos_Path/../site/bin/geolog6_env.tcl" } pgres
    set num [regexp -line {(?:[#]\W)|(?:set env\(PNS_HOST\) (\S+))} $pgres -> g_pns]
    if { $num } {
        puts "GET_PNS: $g_pns : $pgres"
        set pgres PNS_HOST=$g_pns
    }
} else { set pgres "" }
puts "GET_PNS: $pgres"
set pns_host $local_host
foreach pl [split $pgres "\n"] {
    set num [regexp -line {^(?!\W*#\W*])PNS_HOST=([^ ]*)} ${pgres} -> _pns_host]
    if {$num} { 
        puts "GET_PNS: _pns $_pns_host"
        set pns_host $_pns_host 
    }
}
puts "PNS: $pns_host"

if { ![string equal $local_host $pns_host]} {
    catch { exec ping -c 1 $pns_host } pres
    set pres_ ""
    regexp {time=([^ ]*)} $pres -> pres_
    if { [string length $pres_] > 0 } {puts "$pns_host pinged OK"} else {
        puts "no ping to $pns_host!..." 
        tk_messageBox -parent .top43 -icon error -title "Paradigm Software Launcher" -message "PNS server \[ $pns_host \] is down!(No ping)" 
        set pns_host $local_host
    }
}
set get_pns_host $pns_host
return $pns_host
}
#############################################################################
## Procedure:  run_as_user

proc ::run_as_user {cmd} {
global widget
global cmd_env
global Epos_Ver
global Use_Shell

pgenv
puts "RAU: env = $cmd_env"
puts "RAU: cmd = $cmd"
if { $Use_Shell } {
set Cap "$Epos_Ver ([string range $cmd [string last "/" $cmd ] end ])"
#setenv PG_ARG_log_level DEBUG;
catch { exec xterm -sl 10240 -hold -geom 300x80 -T "$Cap" -n "$Cap" -e "$cmd_env;setenv PG_ARG_log_level DEBUG;setenv PG_DEBUG yes;$cmd" \& } result
} else {
catch { exec /bin/csh -c "$cmd_env;$cmd" \& } result
}
set run_as_user $result
}
#############################################################################
## Procedure:  check_bin_set_sens

proc ::check_bin_set_sens {bin_names menu_index} {
global widget
global Epos_Path
global cmd_env
global Epos_arch_Path
global Epos_binary

if { [string length $Epos_binary] ==0 } {
    set pre_cmd ""
} else {
    set pre_cmd "$Epos_binary -cmd="
}

.top43.men49.m entryconfigure $menu_index -state disabled
# check if binary exist...
foreach bin_ $bin_names {
    set res_app [file exist $Epos_Path/$bin_]
#    set res_bin [file exist $Epos_arch_Path/bin/$bin_]
    if { $res_app  } {
        .top43.men49.m entryconfigure $menu_index -state normal
        .top43.men49.m entryconfigure $menu_index -command "run_as_user \"$pre_cmd$Epos_Path/$bin_\""
    }
#    if { $res_bin  } {
#        .top43.men49.m entryconfigure $menu_index -state normal
#    }
#    puts "$Epos_Path/bin/$bin_ binary exist=$res_app"
#    puts "$Epos_arch_Path/bin/$bin_ binary exist=$res_bin"
}
}
#############################################################################
## Procedure:  set_admin_sens

proc ::set_admin_sens {} {
global widget

global PNS_host
global PNS_dir
global Epos_Path

if { [string equal $PNS_host "undefined" ] } {
.top43.lab43.men46.m entryconfigure 2 -state disabled
.top43.lab43.men46.m entryconfigure 3 -state disabled
.top43.lab43.men46.m entryconfigure 4 -state disabled
.top43.lab43.men46.m entryconfigure 6 -state disabled
.top43.lab43.men46.m entryconfigure 7 -state disabled
.top43.lab43.men46.m entryconfigure 9 -state disabled
} else {
.top43.lab43.men46.m entryconfigure 2 -state normal
.top43.lab43.men46.m entryconfigure 3 -state normal
.top43.lab43.men46.m entryconfigure 4 -state normal
.top43.lab43.men46.m entryconfigure 9 -state normal
.top43.lab43.men46.m entryconfigure 6 -state normal
.top43.lab43.men46.m entryconfigure 7 -state normal
}

if { [file exist "$Epos_Path/bin/PG_epos_config"] } {
.top43.lab43.men46.m entryconfigure 6 -state normal
.top43.lab43.men46.m entryconfigure 7 -state normal
} else {
.top43.lab43.men46.m entryconfigure 6 -state disabled
.top43.lab43.men46.m entryconfigure 7 -state disabled
}


check_bin_set_sens "bin/pg3 bin/pg4 bin/pg41 bin/pgstart" 0
check_bin_set_sens "Geolog/bin/geolog geolog7.2/bin/geolog geolog7.1/bin/geolog bin/geolog bin/geolog6 geolog geolog6" 1
check_bin_set_sens "Modeling/bin/Gocad Modeling/Gocad/bin/gocad Gocad" 2
check_bin_set_sens "Modeling/bin/SKUA SKUA" 3
check_bin_set_sens "bin/Echos Echos" 4

#.top43.but44 configure -state [.top43.lab43.men46.m entrycget 2 -state]

if { [file exist $Epos_Path/bin/PPM] } {
.top43.but48 configure -state normal
} else {
.top43.but48 configure -state disabled
}
}
#############################################################################
## Procedure:  get_pns_ver

proc ::get_pns_ver {pns_path} {
global widget

catch { exec grep PG_BUILD $pns_path/pgarch } pns_ver_
#puts "tmp: $pns_ver_"
set pns_ver [ lindex [ split [lindex [split $pns_ver_ "@"] 1 ] " " ] 0 ]

set get_pns_ver $pns_ver
}
#############################################################################
## Procedure:  get_app_ver

proc ::get_app_ver {app_path} {
global widget
global Epos_binary
global Epos_Path


catch { exec grep PG_BUILD $app_path/bin/pgarch } app_ver_
puts "GET_APP_VER tmp: $app_ver_"
set app_ver [ lindex [ split [lindex [split $app_ver_ "@"] 1 ] " " ] 0 ]

set get_app_ver $app_ver
return $app_ver


if { [file exist $Epos_Path/bin/pg3] } {
catch { exec /bin/csh -c "$cmd_env;pg3 -s && cat ~/Epos3_env* | grep PNS_HOST | grep -v hostname | awk '{print \"PNS_HOST=\"\$NF}'" } pgres
set Epos_binary "pg3"
} elseif { [file exist $Epos_Path/bin/pg4] } {
catch { exec /bin/csh -c "$cmd_env;pg4 -cmd=env | grep PNS_HOST" } pgres
set Epos_binary "pg4"
} elseif { [file exist $Epos_Path/bin/pg41] } {
catch { exec /bin/csh -c "$cmd_env;pg41 -cmd=env | grep PNS_HOST" } pgres
set Epos_binary "pg41"
} elseif { [file exist $Epos_Path/bin/pgstart] } {
catch { exec /bin/csh -c "$cmd_env;pgstart -cmd=env | grep PNS_HOST" } pgres
set Epos_binary "pgstart"
}
puts "GET_APP_VER: Epos_Binary $Epos_binary"
}
#############################################################################
## Procedure:  show_lpm

proc ::show_lpm {} {
global widget
global LPM_paths
global LPM_names
global LPM_dir
global LPM_name
global PNS_host
global PNS_dir
global Epos_Ver

global LPM_running_path
global LPM_fileName

Window show .top55
Window show .top55

set pns_listbox .top55.lis84
bind $pns_listbox <<ListboxSelect>> [list set_list_sel %W]
Label106 configure -text "PNS servers configured on \"$PNS_host\":\n(click an item to see PNS path)"
wm title .top55 "PNS manager @ $PNS_host"
#getting currently running PNS path
set cmd [concat ps -do cmd | grep pns_server | grep -v grep]
set error_ssh [get_remote_cmd_result $PNS_host $cmd]
set run_path {}
regexp {^(/\S*)/pns_server} $error_ssh -> run_path
regexp {^(.*)/arch/} $run_path -> run_path
set run_path $run_path/bin
puts "RUN: $run_path"

#getting list of available PNS servers on PNS host
set cmd [concat grep pns_server /etc/init.d/* | grep /arch/]
set daemons_ [get_remote_cmd_result $PNS_host $cmd]

#puts "DMN: $daemons_"
set daemons [split $daemons_ "\n" ]
set LPM_paths {}
set LPM_names {}
set LPM_dir {}
set LPM_name {}
Listbox1 delete 0 end

foreach d $daemons {
puts "PNS_LINE: $d"
catch { regexp {^(/\S*):.*[' ](/\S*/)pns_server} $d -> name path } err
regexp {^(.*)/arch/} $path -> path
set path $path/bin
puts "ERR: $err"
puts "Deamon: name:$name path:$path"
if { [file exists $path] } {
    lappend LPM_names $name
    lappend LPM_paths $path
} else { puts "$name: path $path doesn't exist" }
}

#add SELECTED EPOS PNS 
puts "Selected PNS: $PNS_dir"
if { [file exist $PNS_dir/pns_install_service] } {
    set found_idx [lsearch $LPM_paths $PNS_dir]
    if { $found_idx > -1 } {
        set LPM_names [lreplace $LPM_names $found_idx $found_idx]
        set LPM_paths [lreplace $LPM_paths $found_idx $found_idx]
    } 
lappend LPM_names "$Epos_Ver (default Services path)"
lappend LPM_paths $PNS_dir
}

# add items from pns versions file
if { $::argc < 2  || [string length [lindex $::argv 1] ] == 0 } {
set LPM_fileName "./pnsversions"
puts "Script location: [file dirname $::argv0]"
} else {
set LPM_fileName [lindex $::argv 1]
}

puts "LPM_file: $LPM_fileName"
if { [ file exist $LPM_fileName ] } {
set ver_lines {}
catch {set v_file [open $LPM_fileName r]} openres
if { [regexp {^file[0123456789]*} $openres ] } {
set contents [read -nonewline $v_file] 
close $v_file 
set ver_lines [split $contents "\n"] 
} else {
  #  tk_messageBox -icon error -title "Paradigm Software Launcher" -message "PNS Versions file <$LPM_fileName> cannot be opened for reading!"
     
}
#parse PNS versions file
foreach ver_line  $ver_lines {
#               regexp {^[ \t]*([^#]\S*)[\t ]+(/\S*)[\t ]*(.*)} $ver_line -> ver path comm ]
    set nmatch [ regexp {^[ \t]*([^#]\S*)[\t ]+(/\S*)[\t ]*(.*)} $ver_line -> ver path comm ]
    puts "LINE: $ver_line"
#    puts "matches $nmatch"
    if { $nmatch } {
        set ver [ string trim $ver ]
	set path [ string trim $path ]
        set comm [ string trim $comm ]
        if { [ regexp {^#(.*)}  $comm -> comm2] } {
    	    set comm [string trim $comm2]
        }
        # make lists
        if { [string length [string trim $comm]] < 1 } {
        set comm $ver
        }
        if { [ file exists $path] == 1 } {
            set found_idx [lsearch $LPM_paths $path/bin]
            if { $found_idx > -1 } {
                set LPM_names [lreplace $LPM_names $found_idx $found_idx]
                set LPM_paths [lreplace $LPM_paths $found_idx $found_idx]
            } 
            lappend LPM_names $comm
            lappend LPM_paths $path/bin
        } else {
        puts "Warning: Version $comm has non-existing path ($path)"
        }
    } 
}
} 
# end of if LPM exists
 

# fuill list and activate running PNS
set LPM_running_path {}
set LPM_name [lindex $LPM_names 0]
set LPM_dir [lindex $LPM_paths 0]
Listbox1 selection set 0
foreach i $LPM_names {
    puts "NM: $i RUN:$run_path"
    set path [lindex $LPM_paths [lsearch $LPM_names $i]]
    add_lpm_item $i $path $run_path
}
return
puts "LPM: $LPM_name"
#wm state .top55 normal
#wm protocol .top55 WM_WINDOW_DELETE {wm state .top55 withdrawn}
}
#############################################################################
## Procedure:  set_list_sel

proc ::set_list_sel {w args} {
global widget
global LPM_paths
global LPM_names
global LPM_dir
global LPM_name
global LPM_running_path

set LPM_idx [Listbox1 curselection] 
set LPM_dir [lindex $LPM_paths $LPM_idx ]
set LPM_name [lindex $LPM_names $LPM_idx ]
#puts "SEL: $LPM_idx $LPM_dir $LPM_running_path "
if { [string equal $LPM_running_path $LPM_dir ] } {
    ButtonPNSstart configure -text "Restart selected PNS"
    ButtonPNSstop configure -state normal
} else {
    ButtonPNSstart configure -text "Start selected PNS"
    ButtonPNSstop configure -state disable
}
#puts "SEL: $LPM_idx\"$LPM_dir\""
LPM_path_lab configure -text "$LPM_dir"
}
#############################################################################
## Procedure:  get_remote_cmd_result

proc ::get_remote_cmd_result {host cmd_} {
global widget

set TS [clock seconds]
set cmd [concat "xterm -T 'Login to $host' -e \"ssh -X $host '$cmd_' > ~/pnspath.$TS\"; cat ~/pnspath.$TS;rm -f ~/pnspath.$TS"]
puts "CMD: $cmd"
catch { exec /bin/csh -c  $cmd } error_ssh
#puts "SSH: $error_ssh"
set get_remote_cmd_result $error_ssh
return $error_ssh
}
#############################################################################
## Procedure:  get_remote_cmd_result_as

proc ::get_remote_cmd_result_as {user host cmd_} {
set TS [clock seconds]
set cmd [concat "xterm -T 'Login to $host as $user' -e \"ssh -X $user@$host '$cmd_' > ~/pnspath.$TS\"; cat ~/pnspath.$TS;rm -f  ~/pnspath.$TS"]
puts "CMD: $cmd"
catch { exec /bin/csh -c  $cmd } error_ssh
#puts "SSH: $error_ssh"
set get_remote_cmd_result $error_ssh
return $error_ssh
}
#############################################################################
## Procedure:  daemon_op

proc ::daemon_op {host daemon op} {
global PNS_host

puts "PNS:$host LPM:$daemon op:$op"
set cmd [concat echo $daemon $op...\;$daemon $op\; sleep 5 ]
puts "CMD: $cmd"
set result [get_remote_cmd_result_as root $PNS_host $cmd ]
puts "RES: $result"
}
#############################################################################
## Procedure:  add_lpm_item

proc ::add_lpm_item {name path run_path} {
global widget
global LPM_name
global LPM_dir
global LPM_running_path

    if { [string equal $run_path $path] } { 
        Listbox1 insert end [format "%-50s \[%s\] (running now)" $name [get_pns_ver $path] ] 
        set LPM_dir $path
        set LPM_name $name
        set LPM_running_path $run_path
        Listbox1 selection set end 
    } else { 
        Listbox1 insert end [format "%-50s \[%s\]" $name [get_pns_ver $path] ]}

event generate .top55.lis84 <<ListboxSelect>>
}
#############################################################################
## Procedure:  show_licsync

proc ::show_licsync {} {
global widget
global Epos_Path
global fileName

global LicSrvList
global LicSrv
global FeatList

global Srv_Lic_log
global PG_Lic_log

global Srv_Log_lines
set Srv_Log_lines {}

global LogFiltBy

# Reading Active Features  File .CSV
global APF_list
set APF_list {}
set APF_fn [file dirname $::argv0]/PGL.apfl
if { [ file exist $APF_fn ] } {
    catch {set v_file [open $APF_fn r]} openres
    if { [regexp {^file[0123456789]*} $openres ] } {
    set contents [read -nonewline $v_file] 
    close $v_file 
    set APF_list [split $contents "|"] 
    }
}

Window show .top44
Search_feat configure -vcmd {} 
Window show .top44

.top44 configure -cursor {}

set licsrv_listbox Lic_Serv_list
bind $licsrv_listbox <<ListboxSelect>> [list set_list_Serv_sel %W]
set licftr_listbox Features_list
bind $licftr_listbox <Double-Button-1> { puts "single-1!" }
bind $licftr_listbox <Double-1> { puts "double-1!" }
#bind $licftr_listbox <<ListboxSelect>> [list set_list_Feat_sel %W]
#bind $licftr_listbox <Double-1> "set_list_Feat_click %W"
set liclogdate_listbox .top44.fra54.fra44
bind $liclogdate_listbox.lis44 <<ListboxSelect>> [list set_list_LogDate_sel %W]

Search_feat configure -vcmd {set_ent_Search %P}

#set searchbox Search_feat
#bind $searchbox <KeyPress> {puts "Search: pressed"}

SelSyncFile configure -state disabled
SaveLic configure -state disabled
RestartLic configure -state disabled
PGLMrestart configure -state disabled
Lic_info configure -text "License File info:\n\n\n\n\n\n\n\n\n"

Lic_Serv_list delete 0 end
Features_list delete 0 end
LicLogBox delete 0 end
LicLogBox insert end "License server logging info:"
LogDateBox delete 0 end

set LicSrvList {}
set LicSrv {}
set FeatList {}
set Srv_Lic_log {}
set cmd ""

if { [file exist $Epos_Path/bin/pg3] } {
set cmd pg3
} elseif { [file exist $Epos_Path/bin/pg4] } {
set cmd pg4
} elseif { [file exist $Epos_Path/bin/pg41] } {
set cmd pg41
} elseif { [file exist $Epos_Path/bin/pgstart] } {
set cmd pgstart
}
puts "CMD: $cmd"

set cmd [concat "$Epos_Path/bin/$cmd -cmd='env | grep -e _LICENSE | grep -v grep'" ]
catch {exec /bin/csh -c $cmd} env_lic
puts "ENV_LIC: $env_lic"
if { [string first "_LICENSE_FILE" $env_lic] < 0 } {
    set cmd [concat env | grep -e _LICENSE_FILE | grep -v grep ]
    catch {exec /bin/csh -c $cmd} env_lic
    puts "ENV_LIC: $env_lic"
}
if { [string first "_LICENSE_FILE" $env_lic] < 0 } {
    return
}

foreach lic_env_line $env_lic {
    puts "LIC_LINE: $lic_env_line"
    set num [regexp {LICENSE_LOG=(.*)} $lic_env_line -> liclog_ ]
    if { $num > 0 } { 
        set PG_Lic_log $liclog_ 
        puts "LIC_PG_LOG: $PG_Lic_log"
    }
    foreach lic_serv [split $lic_env_line ":"] {
        #getting currently running License servers and license files path
        puts "LIC_SERV: $lic_serv"
        set num [ regexp {.*\S*\@(\S*)} $lic_serv -> licsrv ]
        if { $num > 0 } { 
            puts "LICSRV: $licsrv"
            puts "EXISTS: [lsearch $LicSrvList $licsrv]"
            if { [lsearch $LicSrvList $licsrv] < 0 } {
                Lic_Serv_list insert end $licsrv
                lappend LicSrvList $licsrv
            }
        }
    }
}

if { $LogFiltBy } {
} else { set LogFiltBy 1 }
#select_LogFilter $LogFiltBy
}
#############################################################################
## Procedure:  set_list_Feat_sel

proc ::set_list_Feat_sel {w args} {
global widget

set fsel [Features_list curselection]
if { [llength $fsel] } { 
    RestartLic configure -state normal 
    SaveLic configure -state normal 
} else {
    RestartLic configure -state disabled
    SaveLic configure -state disabled
}

#set_list_Feat_click $w 0 0
}
#############################################################################
## Procedure:  set_list_Serv_sel

proc ::set_list_Serv_sel {w args} {
global widget
global LicSrvList
global LicSrv
global fileName
global FeatList
global Srv_Lic_lines
global Srv_user
global Srv_Lic_file
global Srv_Lic_log

puts "LIC_SRV_NUM: [llength $LicSrvList]"
set LS_idx [Lic_Serv_list curselection] 
puts "LIC_IDX: $LS_idx"
set LicSrv [lindex $LicSrvList $LS_idx ]
if { [string length $LicSrv] <1 } {return}
puts "LIC_SRV: $LicSrv"
    set licsrv $LicSrv
    Features_list delete 0 end
    SaveLic configure -state disabled 
    RestartLic configure -state disabled 
    Lic_info configure -text "License File info:\n\n\n\n\n\n\n\n\n"
    set cmd [concat ps -do uid,cmd | grep lmgrd | grep -v grep]
    set adm_user [file attributes $fileName -owner]
    set error_ssh [get_remote_cmd_result $licsrv $cmd]
    puts "SSH_LIC: $error_ssh"
    set Srv_user_uid {}
    regexp {^\W*(\d*)\W+} $error_ssh -> Srv_user_uid
    puts "SSH_LIC: UID: $Srv_user_uid"
    set cmd [concat getent passwd $Srv_user_uid]
    set error_ssh2 [get_remote_cmd_result $licsrv $cmd]
    puts "SSH_LIC: $cmd"
    puts "SSH_LIC: $error_ssh2"
    set Srv_user [lindex [split $error_ssh2 ":"] 0]
    puts "SSH_LIC: USER: $Srv_user"
    set lic_file_ {}
    puts "LIC_SEL: $error_ssh"
    set num [ regexp {lmgrd\s+.*-c\s+(\S+)} $error_ssh -> lic_file_ ]
    if { $num == 0  } {
        puts "LIC_SEL: failed"
    } 
    set lic_file [string map { { } {\ }  } $lic_file_]
    set Srv_Lic_file $lic_file
    puts "LIC_FILE: $lic_file"
    set Srv_Lic_log ""
    set Srv_Lic_lines {}
    ### reading license file's features
    if { [string length $lic_file] > 1 } { 
        set ver_lines {}
        set FeatList {}
        set cmd [concat cat $lic_file]
        set contents [get_remote_cmd_result $licsrv $cmd]
        #puts "LIC_CONTENTS: $contents" 
        if { [string length $contents] <1 || [string first "Permission denied" $contents] > -1 || [string first "not found" $contents] > -1} {
            set contents [get_remote_cmd_result_as $Srv_user $licsrv $cmd]
        }
        set ver_lines [split $contents "\n"]
        set Srv_Lic_lines $ver_lines
        #parse LICENSE versions file
        set hdr 1
        set lfheader {}
        foreach ver_line  $ver_lines {
        #               regexp {^[ \t]*([^#]\S*)[\t ]+(/\S*)[\t ]*(.*)} $ver_line -> ver path comm ]
            set nmatch [ regexp {[FI][EN][AC][TR][UE][RM]E\S* (\S*) \S* \S* (\S*) (\S*)} $ver_line -> ftname ftdate ftnum]
                if { $nmatch } {
                set hdr 0
            #puts "LINE: $ver_line"
                lappend FeatList $ftname
                Features_list insert end [format "%-33s count:%-5s  expires %s" $ftname $ftnum $ftdate]
            }
            if { $hdr } {
                append lfheader $ver_line\n
            }
        }
        Lic_info configure -text "License file header:\n$lfheader"
    }

PGLMrestart configure -state normal
if { [ llength $FeatList] } { SelSyncFile configure -state normal } { SelSyncFile configure -state disabled }
#if { [Lic_Serv_list size] && [llength [Lic_Serv_list curselection]] } { RestartLic configure -state normal } {RestartLic configure -state disabled}
set Srv_Lic_log ""
set_ent_Search [Search_feat get]
set_list_Log_sel LicLogBox
puts "Serv_list_sel: $LicSrv"
}
#############################################################################
## Procedure:  save_feat_file

proc ::save_feat_file {filename Comment} {
global widget
global User_LicFile

global Srv_Lic_lines
global FeatList

set user_file {}
if { [string length $User_LicFile] } {
    set user_file [file tail $User_LicFile]
}    

set feat_mathes {}
if { [string length $filename ] } {
    set trg_file [open $filename "w+"]
    set do_write 1
    set sel_feat {}
    foreach fidx [Features_list curselection] {
        lappend sel_feat [lindex $FeatList $fidx]
    }
    #set sel_feat [lindex $FeatList $sel_feat_idx]
    puts "SEL_FEATURES idx: [Features_list curselection] "
    set trg_lines {}
    puts -nonewline $trg_file "# $Comment\n# Customer License: $user_file\n"
    foreach src_line  $Srv_Lic_lines {
        set nmatch [ regexp {[FI][EN][AC][TR][UE][RM]E\S* (\S*) \S* \S* (\S*) (\S*)} $src_line -> ftname ftdate ftnum]
        if { $nmatch } {
        #puts "LINE: $ver_line"
        set do_write 0
        foreach feat $sel_feat {
            if { [string equal $feat $ftname] } { 
                set do_write 1 
                puts "SET_WRITE: $ftname"
            }
        }
        }
        if { $do_write } { 
            #
            #puts "WRITE: $src_line"
            puts -nonewline $trg_file $src_line\n
        }
    }
#    puts -nonewline $trg_file $trg_lines
    close $trg_file 
}
}
#############################################################################
## Procedure:  set_ent_Search

proc ::set_ent_Search {var} {
global widget
global FeatList
#puts "Search: $var"

if { [llength $FeatList] <1 || [Features_list size] <1 } {return 1}
set idx 0
set defbkg [Features_list cget -background]
set see1st 1
set found_count 0

catch { regexp $var "aaa" } res
#puts "Search: \[$var\] : \[$res\]"
if { [string first "couldn't compile regular expression pattern:" $res] == -1 } {
foreach f $FeatList {
    if { [string equal [Features_list itemcget $idx -background] "yellow" ] } {
        Features_list itemconfigure $idx -background $defbkg
    }
    if { [string length $var] && [regexp $var $f] > 0 } {
        if { $see1st } { 
            Features_list see $idx 
            set see1st 0
        }
        #puts "FOUND: $var @ $idx"
        set found_count [expr $found_count + 1]
        Features_list itemconfigure $idx -background yellow 
    }
    set idx [expr $idx + 1]
}
}
Found_lab configure -text "Found: $found_count match(es)"
return 1
}
#############################################################################
## Procedure:  set_ent_AddSrv

proc ::set_ent_AddSrv {var} {
global widget
global FeatList
global Add_Lic_Srv
#puts "Search: $var"

set num [regexp {\S+ +} $var]
#puts "ADDSRV: $num : $var"
if { [string length $var] < 3 || $num } {
    add_srv_but configure -state disabled
    set Add_Lic_Srv {}
#    puts "name $var BAD"
} else {
    set var [string trim $var]
    add_srv_but configure -state normal
    set Add_Lic_Srv $var
#    puts "name $var OK"
}
return 1
}
#############################################################################
## Procedure:  set_list_Log_sel

proc ::set_list_Log_sel {w args} {
global widget
global Srv_Lic_log
global Srv_Lic_file
global LicSrv
global Srv_user
global Srv_Lic_lines
global Srv_Log_lines

LicLogBox delete 0 end
LogDateBox delete 0 end
set Srv_Log_lines {}

puts "LOGS: SRV: $LicSrv"
if { [string length $LicSrv] <1 } { return }

LicLogBox insert end "License server \[$LicSrv\] logging info:"
set Log_contents ""

if { [string length $LicSrv] <1 } { return }

if { [string first "Saved by PGL for Restarting" $Srv_Lic_lines] > -1 && [string first "PGL_license.lic" $Srv_Lic_file] > -1} {
#    set custom_lic_file [ concat $::env(HOME)/license.dat ] 
#    set logfil_ [concat /tmp/[ file tail $custom_lic_file ].log]
    set logfil_ $Srv_Lic_file.log
    set cmd [concat cat $logfil_]
    set Log_contents [get_remote_cmd_result $LicSrv $cmd]
    #puts "LOG_CONTENTS: $Log_contents" 
    if { [string length $Log_contents] <1 || [string first "Permission denied" $Log_contents] > -1 || [string first "not found" $Log_contents] > -1 } {
        set Log_contents [get_remote_cmd_result_as $Srv_user $LicSrv $cmd]
    }
    puts "LIC_LOG: from tmp: [string length $Log_contents]"
    if { [ string length $Log_contents] } { set Srv_Lic_log $logfil_}
}
if { [ string length $Log_contents] < 1 && [string length $Srv_Lic_log]>1 } { 
    set cmd [concat cat $Srv_Lic_log]
    set Log_contents [get_remote_cmd_result $LicSrv $cmd]
    if { [string length $Log_contents] <1 || [string first "Permission denied" $Log_contents] > -1 || [string first "not found" $Log_contents] > -1} {
        set Log_contents [get_remote_cmd_result_as $Srv_user $LicSrv $cmd]
    }
    puts "LIC_LOG: from running server: [string length $Log_contents]"
} 

if { [ string length $Log_contents] < 1 } {
    set cmd [concat cat /etc/init.d/PG_lmgrd_startup_script]
    set init_file [get_remote_cmd_result $LicSrv "cat /etc/init.d/PG_lmgrd_startup_script"]
    #puts "SRCIPT: $init_file"
    foreach line [split $init_file "\n" ] {
        set num [regexp {>>\W*([$/]\S+)\W*\"} $line -> logfil_ ]
        if { $num > 0 } {
                set uhd [string first {$userHomeDir} $logfil_ ]
                puts "UHD: $uhd"
                if { $uhd >= 0 } {
                    puts "REPL: $logfil_"
                    set logfil_ [ string replace $logfil_ $uhd 11  $::env(HOME)]
                    puts "REPL: $logfil_"
                }
            puts "LOGFIL: $logfil_"
            set cmd [concat cat $logfil_]
            set Srv_Lic_log $logfil_
            set Log_contents [get_remote_cmd_result $LicSrv $cmd]
            if { [string length $Log_contents] <1 || [string first "Permission denied" $Log_contents] > -1 || [string first "not found" $Log_contents] > -1} {
                set Log_contents [get_remote_cmd_result_as $Srv_user $LicSrv $cmd]
            }
            puts "LIC_LOG: from init script: [string length $Log_contents]"
            if { [ string length $Log_contents] } { set Srv_Lic_log $logfil_}
        }
    }
}

#puts "LOG_LINES: $Log_contents"
#set 
#LicLogBox insert end "File: $Srv_Lic_log (last change time: [clock format [file mtime $Srv_Lic_log] -format "%d %b %Y %H:%M"])"
set Srv_Log_lines [split $Log_contents "\n" ]

global LogFiltBy
if { $LogFiltBy ==0 } {set $LogFiltBy 1 } 
set_log_lists $LogFiltBy
return
}
#############################################################################
## Procedure:  set_list_LogDate_sel

proc ::set_list_LogDate_sel {w args} {
global Srv_Log_lines
global LogFiltBy

if { [LogDateBox size] < 1 } { return }  

LicLogBox delete 0 end

.top44 configure -cursor {clock}

set sel [LogDateBox curselection]
set ldate [LogDateBox get $sel]
##puts "LOGDATE: [LogDateBox curselection]"
puts "LOGDATE: selected [LogFbut cget -text]: $ldate"
if { $sel } {
    set out 0
    foreach line $Srv_Log_lines {
    switch $LogFiltBy {
        3   -
        2 {  if { [string first $ldate $line ] > -1} {
                    set out 1 
                } else { 
                    set out 0 
                }
          }
        1  -
        default {
            if { [string first "TIMESTAMP" $line ] > -1} {
                set mdate [string first $ldate $line ] 
                if { $out && $mdate < 0 } { 
                    set out 0 
                } elseif { $out==0 && $mdate > -1 } { 
                    set out 1 
                }
            }
                }
    }
    if { $out == 1 } { LicLogBox insert end $line}
    }
} else {
    foreach line $Srv_Log_lines {
        LicLogBox insert end $line
    }
}
.top44 configure -cursor {}
LicLogBox see end
}
#############################################################################
## Procedure:  select_LogFilter

proc ::select_LogFilter {mode} {
global widget
global LogFiltBy

set LogFiltBy $mode
switch $mode {
    1 {set butt "Date" }
    2 {set butt "User" }
    3 {set butt "Host" }
}
}
#############################################################################
## Procedure:  set_log_lists

proc ::set_log_lists {mode} {
global widget
global Srv_Lic_log
global Srv_Log_lines
global LogFiltBy

LicLogBox delete 0 end 
LogDateBox delete 0 end

LicLogBox insert end "File: $Srv_Lic_log"

switch $mode {
    1 {set LogFilt_txt "Date"}
    2 {set LogFilt_txt "User"}
    3 {set LogFilt_txt "Host"}
    default {set LogFilt_txt "Date"}
}
LogDateBox insert end "$LogFilt_txt: (click - full log)"
.top44 configure -cursor {clock}
puts "START set_log_lists:"
##        2 { set num [ regexp {(\S+)@\S+} $line -> ts_date] }
#      [^(@](\S+)@\S[^@)]\W+
foreach line $Srv_Log_lines {
    switch $mode {
        1  { set num [ regexp {\(lmgrd\)\W+TIMESTAMP (\S+/\S+/\S+)} $line -> ts_date] }
	2 { set num [ regexp {(?=@|\S+)(\w+)@\w+} $line -> ts_date] }
        3 { set num [ regexp {(?=@|\S+)\w+@([\w\-_]+)} $line -> ts_date] }
        default { set num [ regexp {\(lmgrd\)\W+TIMESTAMP (\S+/\S+/\S+)} $line -> ts_date] }
    }
    if { $num } {
        set new 1
        for { set x 0 } { $x < [LogDateBox size] } { incr x } {
            if { [string equal $ts_date [LogDateBox get $x]] } { set new 0 }
        }
        if { $new } { LogDateBox insert end $ts_date }
    }
    if { [string length [string trim $line] ] >0 } { LicLogBox insert end $line}
}
.top44 configure -cursor {}
puts "STOP set_log_lists:"
set LogFiltBy $mode
LogFbut configure -text $LogFilt_txt
LicLogBox see end
}
#############################################################################
## Procedure:  save_last_ver

proc ::save_last_ver {} {
global Epos_Ver
global PGLconf
global PGLconf_geom

    set trg_file [open $PGLconf "w+"]
    puts "SAVE VER: $Epos_Ver"
    puts $trg_file "vers=$Epos_Ver"
    puts $trg_file "geom=$PGLconf_geom"
}
#############################################################################
## Procedure:  set_list_Feat_click

proc ::set_list_Feat_click {w x y} {
global APF_list
global FeatList

set res 0
set Feat_desc "Product:N\\A\nDescription: N\\A"

#set feature [Features_list curselection]
#puts "FLIST: pos=$x:$y"
set feature [Features_list nearest $y]
#puts "FLIST: selection: $feature"
set feat {}
if { [llength $feature] } {
set feat [lindex $FeatList [lindex $feature 0]]
}
if { [llength $feat] } {
#puts "FLIST: feature:$feat"
set j -3
set k -4
set l -5
set m -2
set max_len_ 80
set max_len $max_len_
foreach line $APF_list {
    #puts "FLIST: $feat: $j $k : $line "
    regsub -all {"} $line {} line
    set found [string equal $feat $line]
    if { !$found } {
    foreach f [split $line "\n"] {
        if { [string length $f ] && [string equal $feat $f] } {
            set found 1
            break
        }
        #puts "FLIST: $feat:$line:$f"
    }
    }
    if { $found && $j>0} {
        #puts "FLIST: Product:[lindex $APF_list $k] Descr:[lindex $APF_list $j]"
        set type_ [lindex $APF_list $m]
        regsub -all {"} $type_ {} type_
	regsub -all {\n} $type_ { } type_
        if { [string length $type_] && ([string match $type_ "SB"] || [string match "AO" $type_] || [string match "AO*" $type_] || [string match "P" $type_] || [string match "C" $type_]) } {
            set pid_ [lindex $APF_list $l]
	    regsub -all {"} $pid_ {} pid_
            regsub -all {\n} $pid_ { } pid_
	    set prod_ [lindex $APF_list $k]
            regsub -all {"} $prod_ {} prod_
	    regsub -all {\n} $prod_ { } prod_
            set desc_ [lindex $APF_list $j]
	    regsub -all {"} $desc_ {} desc_
            regsub -all {\n} $desc_ { } desc_
	    set pos_ [string first " " $desc_]
            set lpos_ 0
	    while { $pos_ > 0 } {
                if { [expr $pos_ - $lpos_] > $max_len } {
	            set desc_ [string replace $desc_ $pos_ $pos_ "\n" ]
                    set lpos_ [expr $pos_ + 1 ]
                    if { $max_len == $max_len_ } {incr max_len 15}
	        }
                set pos_ [string first " " $desc_ [expr $pos_ + 1 ] ] 
	    }
            set Feat_desc "Product: \[$type_\] $pid_ $prod_\nDescription: $desc_"
            set res 1
	    if { ![string match $type_ "SB"] } {break}
        }
    }
    incr j
    incr k
    incr l
    incr m
}
    #puts "FEATLIST: res=$res"
    if { !$res } {
        set res [get_Feat_desc $feat 0 ]
        #puts "get_Feat_desc: $res"
        if { [string length $res] } {
            set Feat_desc $res
        }
    } else {
        set type_ [get_Feat_desc $feat 1 ]
        set num [ regexp {\[([^\]]*)} $Feat_desc -> type ]
        #puts "FEATLIST: $type_ $num"
        if { $num } {
            #puts "FEATLIST: $type $type_"
            regsub {\[[^\]]*} $Feat_desc "\[$type,$type_" Feat_desc
        }
    }
}
Feat_detail configure -text $Feat_desc
}
#############################################################################
## Procedure:  load_config

proc ::load_config {} {
global PGLconf
global PGLconf_geom
global PGLconf_vers

set PGLconf_vers "undefined"
set PGLconf_geom ""
if { [file exist $PGLconf ] } {
catch { exec cat $PGLconf } last_ver_
puts "PGLCONF: config:\n$last_ver_"
regexp -line {vers=(.+)} $last_ver_ -> PGLconf_vers
regexp -line {geom=(\S+)} $last_ver_ -> PGLconf_geom
puts "PGLCONF: \[$PGLconf_vers\] \[$PGLconf_geom\]"
#set LastVer $last_ver_
} 
}
#############################################################################
## Procedure:  check_scan_paths

proc ::check_scan_paths {versions} {
global ver_lines

set scan1 ""
set scan2 ""
set scan3 ""
set s "check_scan_paths: "
set scanID 0
set pathID 0
set line_idx -1 
set n [llength $ver_lines]
puts $s$n\n

foreach line  $versions {
	#puts $s$line
	set line_idx [expr $line_idx + 1]
	set comment [regexp {(^#+)} $line]
	if {$comment || [string length [string trim $line]]<3 } continue
	set scan1 [regexp {^scan} $line]
	if {$scan1} { 
		set scan2 [regexp {^scan\W+(/\S+)\W+\S+} $line -> path]
		set scan3 [regexp {^scan\W+/\S+\W+(\S+.*$)} $line -> comm]
		if {$scan2 & $scan3} {
			set s "check_scan_paths: scan path detected:"
			#puts [ concat $s "|" $path "|" $comm ]
			if { [file exist $path ] } { 
				set scandirs [glob -nocomplain -type d [concat $path/* ] ]
				set scanID [expr $scanID + 1]
				set pathID 0				
				foreach scanpath $scandirs {
					set s "scan: "
					set scan1 [regexp {.*/(.*)$} $scanpath -> vname]
					if { $scan1 } { 
						set pathID [expr $pathID + 1 ]
                                                set app_suf "Applications"
						set newline [concat s${scanID}p${pathID}   $scanpath/$app_suf    #$comm - $vname\n]
						lappend ver_lines $newline
						#puts $s$newline
					}
				}
				#puts $s$line_idx
				#set ver_lines [lreplace $ver_lines $line_idx $line_idx ## ]				
				#set line_idx [expr $line_idx - 1]
				#puts [ concat $s "|" $scandirs ]
			} 
			set ver_lines [lreplace $ver_lines $line_idx $line_idx ## ]				
			#set line_idx [expr $line_idx - 1]
		}
		
	}
	
}

set s "check_scan_paths: result: "
set n [llength $ver_lines]
puts $s$n\n

#foreach line  $ver_lines {
#	puts $s$line
#}
}
#############################################################################
## Procedure:  get_Feat_desc

proc ::get_Feat_desc {feat mode} {
global APF_xml_list

set Feat_desc ""
if { [llength $feat] } {
#puts "FLIST: [llength $APF_xml_list] feature:$feat"
set type_ "n\\a"
set prod_ "n\\a"
set feat_ "n\\a"
set desc_ "n\\a"
set max_len_ 80
set max_len $max_len_
foreach line $APF_xml_list {
  if { [string first $feat $line] > 0 } {
    set num1 [regexp {<(\S+)(?:_Products|_Features)} $line -> type_] 
    set num3 [regexp {License_Package\W*=\W*"([^"]*)} $line -> feat_] 
    if { $mode == 0 } {
        set num2 [regexp {(?:parent_X0020_BP|Product)\W*=\"([^"]*)} $line -> prod_] 
        set num4 [regexp {Description\W*=\W*"([^"]*)} $line -> desc_] 
    }
    #set num [regexp {<(\S+)_Products.*parent_.*=\"(.*)\".*License_Package=\"(\S+)\".*Description=\"(.+)\"} $line -> type_ prod_ feat_ desc_] 
    #if { $num1 || $num2==1 || $num3==1 || $num4 == 1 } { puts "FLIST_XML: $feat : $type_|$prod_|$feat_|$desc_" }
    switch $type_ {
        "Add-on" {set type_ "EAO"}
        "Supplementary" {set type_ "AO"}
        "Companion" {set type_ "CP"}
        "Basic" {set type_ "P"}
        default {}
    }
    if { $mode == 1 } {
        if { $num1 } {set Feat_desc $type_}
    } else {
        set found 0
        foreach f [split $feat_ "+"] {
            if { [string equal $f $feat] } {set found 1}
        } 
        if { $num1 && $num2 && $num3 && $found } {
	    set pos_ [string first " " $desc_]
            set lpos_ 0
            while { $pos_ > 0 } {
                    if { [expr $pos_ - $lpos_] > $max_len } {
    	                set desc_ [string replace $desc_ $pos_ $pos_ "\n" ]
                        set lpos_ [expr $pos_ + 1 ]
                        if { $max_len == $max_len_ } {incr max_len 15}
    	            }
                    set pos_ [string first " " $desc_ [expr $pos_ + 1 ] ] 
    	    }
            set Feat_desc "Product: \[$type_\] $prod_\nDescription: $desc_"          
        }
        if { [string equal $type_ "P"] } {break}
    }
    
  }
}
}
return $Feat_desc
}
#############################################################################
## Procedure:  resize_bkg

proc ::resize_bkg {geom} {
global BKG_img
global BKG_img_scaled

#puts "IMG:resize [.top43.lab43 cget -width]"
set num [regexp {(\d+)x(\d+)[+-](\d+)[-+](\d+)} $geom -> wid hei dx dy]
if { $num } {
    set hei [expr int($hei*0.56)]
    set wid [expr int($wid*0.9)]
    #puts "IMG: $geom: $wid $hei $dx $dy"
    set xf [expr double($wid)/[image width $BKG_img]]
    set yf [expr double($hei)/[image height $BKG_img]]
    #puts "IMG: xf = $xf yf = $yf"

    set mode -subsample

    if {$xf>=1 || $yf>=1} {
        set mode -zoom
    }
    if {abs($yf) < 1} {
       set yf [expr round(1./$yf)]
    } 
    if {abs($xf) < 1} {
       set xf [expr round(1./$xf)]
    } 
    $BKG_img_scaled blank
    $BKG_img_scaled copy $BKG_img -shrink $mode [expr int(round($xf))] [expr int(round($yf))]
    #resize_photo $BKG_img $wid $hei $BKG_img_scaled
            
    BKG_lab configure -image $BKG_img_scaled
}
}
#############################################################################
## Procedure:  resize_photo

proc ::resize_photo {src newx newy {dest {}}} {
global widget

     
     set mx [image width $src]
     set my [image height $src]
     
     if { "$dest" == ""} {
         set dest [image create photo]
     }
     $dest configure -width $newx -height $newy
     
     # Check if we can just zoom using -zoom option on copy
     if { $newx % $mx == 0 && $newy % $my == 0} {
     
         set ix [expr {$newx / $mx}]
         set iy [expr {$newy / $my}]
         $dest copy $src -zoom $ix $iy
         return $dest
     }
 
     set ny 0
     set ytot $my
     
     for {set y 0} {$y < $my} {incr y} {
         
         #
         # Do horizontal resize
         #
         
         foreach {pr pg pb} [$src get 0 $y] {break}
         
         set row [list]
         set thisrow [list]
         
         set nx 0
         set xtot $mx
         
         for {set x 1} {$x < $mx} {incr x} {
             
             # Add whole pixels as necessary
             while { $xtot <= $newx } {
                 lappend row [format "#%02x%02x%02x" $pr $pg $pb]
                 lappend thisrow $pr $pg $pb
                 incr xtot $mx
                 incr nx
             }
             
             # Now add mixed pixels
             
             foreach {r g b} [$src get $x $y] {break}
             
             # Calculate ratios to use
             
             set xtot [expr {$xtot - $newx}]
             set rn $xtot
             set rp [expr {$mx - $xtot}]
             
             # This section covers shrinking an image where
             # more than 1 source pixel may be required to
             # define the destination pixel
             
             set xr 0
             set xg 0
             set xb 0
             
             while { $xtot > $newx } {
                 incr xr $r
                 incr xg $g
                 incr xb $b
                 
                 set xtot [expr {$xtot - $newx}]
                 incr x
                 foreach {r g b} [$src get $x $y] {break}
             }
             
             # Work out the new pixel colours
 
             set tr [expr {int( ($rn*$r + $xr + $rp*$pr) / $mx)}]
             set tg [expr {int( ($rn*$g + $xg + $rp*$pg) / $mx)}]
             set tb [expr {int( ($rn*$b + $xb + $rp*$pb) / $mx)}]
             
             if {$tr > 255} {set tr 255}
             if {$tg > 255} {set tg 255}
             if {$tb > 255} {set tb 255}
             
             # Output the pixel
 
             lappend row [format "#%02x%02x%02x" $tr $tg $tb]
             lappend thisrow $tr $tg $tb
             incr xtot $mx
             incr nx
             
             set pr $r
             set pg $g
             set pb $b
         }
         
         # Finish off pixels on this row
         while { $nx < $newx } {
             lappend row [format "#%02x%02x%02x" $r $g $b]
             lappend thisrow $r $g $b
             incr nx
         }
         
         #
         # Do vertical resize
         #
         
         if {[info exists prevrow]} {
             
             set nrow [list]
             
             # Add whole lines as necessary
             while { $ytot <= $newy } {
                 
                 $dest put -to 0 $ny [list $prow]
                 
                 incr ytot $my
                 incr ny
             }
             
             # Now add mixed line
             # Calculate ratios to use
             
             set ytot [expr {$ytot - $newy}]
             set rn $ytot
             set rp [expr {$my - $rn}]
             
             # This section covers shrinking an image
             # where a single pixel is made from more than
             # 2 others.  Actually we cheat and just remove 
             # a line of pixels which is not as good as it should be
             
             while { $ytot > $newy } {
                 
                 set ytot [expr {$ytot - $newy}]
                 incr y
                 continue
             }
             
             # Calculate new row
 
             foreach {pr pg pb} $prevrow {r g b} $thisrow {
                 
                 set tr [expr {int( ($rn*$r + $rp*$pr) / $my)}]
                 set tg [expr {int( ($rn*$g + $rp*$pg) / $my)}]
                 set tb [expr {int( ($rn*$b + $rp*$pb) / $my)}]
                 
                 lappend nrow [format "#%02x%02x%02x" $tr $tg $tb]
             }
             
             $dest put -to 0 $ny [list $nrow]
             
             incr ytot $my
             incr ny
         }
         
         set prevrow $thisrow
         set prow $row
         
         update idletasks
     }
     
     # Finish off last rows
     while { $ny < $newy } {
         $dest put -to 0 $ny [list $row]
         incr ny
     }
     update idletasks
 
     return $dest
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {
global ver_lines
global fileName 
global PGL_version
global PGL_date
global LPM_dir
global local_host

global Epos_binary
set Epos_binary ""

global User_LicFile

global G_PNS_host
set G_PNS_host ""

global LogFiltBy
set LogFiltBy 0

global BKG_img
global BKG_img_scaled
# Lading saved PGL configuration
global PGLconf
global PGLconf_geom
global PGLconf_vers
set  PGLconf "$::env(HOME)/.PGLconf"
catch { hostname }  local_host

load_config 

# Loading Image for The background .
global BKG_img
global BKG_img_scaled
set BKG_img_scaled [image create photo]

set BKG_img_fn [file dirname $::argv0]/PGL.gif
puts "IMG: $BKG_img_fn"
if { [file exist $BKG_img_fn] } {
    set BKG_img [image create photo -file $BKG_img_fn]
    #resize_bkg $PGLconf_geom
    #BKG_lab configure -image $BKG_img
}

if { $::argc == 0 || [string length [lindex $::argv 0] ] == 0 } {
set fileName "./pgversions"
puts "Script location: [file dirname $::argv0]"
} else {
set fileName [lindex $::argv 0]
}
if { ![ file exist $fileName ] } {
#set cmd [concat touch $fileName \; echo "#File Format:" > $fileName \; echo "#Version_ID               Path                        #Comment" >> $fileName \; echo "#2011.2           /apps/PDGM/Paradigm-2011.2/Applications         #Example setup" >> $fileName ]
#catch { exec  /bin/csh -c $cmd } result
#puts "RES: $result"
}

set ver_lines {}
catch {set v_file [open $fileName r]} openres
if { [regexp {^file[0123456789]*} $openres ] } {
set contents [read -nonewline $v_file] 
close $v_file 
set ver_lines [split $contents "\n"] 
} else {
    tk_messageBox -icon error -parent . -title "Paradigm Software Launcher" -message "Versions file <$fileName> cannot be opened for reading!"
     
}

check_scan_paths $ver_lines

set PGL_version "1.26"
regexp {^(\S*.tcl)} $::argv0 -> scr_name
set PGL_date [clock format [file mtime $scr_name] -format "%d %b %Y %H:%M"]
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 1x1+0+0; update
    wm maxsize $top 3185 1170
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl.tcl.none.28263"
    bindtags $top "$top Vtcl.tcl.none.28263 all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top43 {base} {
    if {$base == ""} {
        set base .top43
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -background #ffffff -highlightcolor black 
    wm focusmodel $top passive
    wm geometry $top 962x364+29+60; update
    wm maxsize $top 3185 1170
    wm minsize $top 200 200
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "Paradigm Software Launcher (agritsenko@pc-mos-grits)"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    bind $top <<DeleteWindow>> {
        save_last_ver;exit
    }
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    label $top.lab43 \
        -activeforeground #ff0000 -background #ffffff \
        -disabledforeground #a2a2a2 -foreground #ff0000 -height 0 \
        -highlightcolor #ff0000 \
        -image [vTcl:image:get_image [file join PGL.gif]] \
        -text {Paradigm (R)} -underline 1 -width 0 
    vTcl:DefineAlias "$top.lab43" "BKG_lab" vTcl:WidgetProc "Toplevel1" 1
    bind $top.lab43 <Configure> {
        # TODO: your event handler here
global PGLconf_geom
resize_bkg $PGLconf_geom
    }
    label $top.lab43.lab43 \
        -activebackground #f8f8f8 -activeforeground black -background #ffffff \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12 -weight bold"] \
        -foreground black -highlightcolor black \
        -text {Selected Software version:
(to select version click there ->)} 
    vTcl:DefineAlias "$top.lab43.lab43" "Label2" vTcl:WidgetProc "Toplevel1" 1
    menubutton $top.lab43.men44 \
        -activebackground #f8f8f8 -activeforeground black -background #ffffff \
        -borderwidth 1 -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family lucida -size 18"] \
        -foreground black -highlightcolor black -indicatoron 1 -justify left \
        -menu "$top.lab43.men44.m" -padx 6 -pady 4 -relief raised \
        -text {P15.5 release local @ pnsmos2013} -wraplength 640 
    vTcl:DefineAlias "$top.lab43.men44" "Menubutton1" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.lab43.men44 "$top.lab43.men44 Menubutton $top all _vTclBalloon"
    bind $top.lab43.men44 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Click here to select another available Software Version}
    }
    menu $top.lab43.men44.m \
        -activebackground #f8f8f8 -activeforeground black \
        -disabledforeground #a2a2a2 -foreground black -tearoff 0 
    $top.lab43.men44.m add command \
        -command { select_ver 0 } -label {Epos3TE & Focus 5.4} 
    $top.lab43.men44.m add command \
        -command { select_ver 1 } -label {Epos4 old (NO Rollup3!!!)} 
    $top.lab43.men44.m add command \
        -command { select_ver 2 } -label {Epos4 Rollup4} 
    $top.lab43.men44.m add command \
        -command { select_ver 3 } -label {Geolog 7.0p2} 
    $top.lab43.men44.m add command \
        -command { select_ver 4 } -label {Geolog 6.7.1} 
    $top.lab43.men44.m add command \
        -command { select_ver 5 } -label {P2011.0 very old} 
    $top.lab43.men44.m add command \
        -command { select_ver 6 } -label {P2011.1 old} 
    $top.lab43.men44.m add command \
        -command { select_ver 7 } -label P2011.2 
    $top.lab43.men44.m add command \
        -command { select_ver 8 } -label {Release P2011.3 (27May2013)} 
    $top.lab43.men44.m add command \
        -command { select_ver 9 } -label {P14 release local} 
    $top.lab43.men44.m add command \
        -command { select_ver 10 } -label {P14.1 release local} 
    $top.lab43.men44.m add command \
        -command { select_ver 11 } -label {P15 release local} 
    $top.lab43.men44.m add command \
        -command { select_ver 12 } -label {P15.5 release local} 
    button $top.lab43.but44 \
        -activebackground #f8f8f8 -activeforeground black -borderwidth 0 \
        -command {run_as_user "firefox [file dirname $::argv0]/help/PGL_ReleaseNotesF.htm"} \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family courier -size 12"] \
        -foreground black -highlightcolor black -padx 1m -text Help 
    vTcl:DefineAlias "$top.lab43.but44" "Button4" vTcl:WidgetProc "Toplevel1" 1
    menubutton $top.lab43.men46 \
        -activebackground #f8f8f8 -activeforeground black \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family courier -size 12"] \
        -foreground black -highlightbackground #ffffff -highlightcolor black \
        -justify left -menu "$top.lab43.men46.m" -padx 6 -pady 4 \
        -text Administration 
    vTcl:DefineAlias "$top.lab43.men46" "Menubutton2" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.lab43.men46 "$top.lab43.men46 Menubutton $top all _vTclBalloon"
    bind $top.lab43.men46 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Here you can run Appications and Services management consoles and edit versions list file}
    }
    menu $top.lab43.men46.m \
        -activebackground #f8f8f8 -activeforeground black \
        -disabledforeground #a2a2a2 -foreground black -tearoff 0 
    $top.lab43.men46.m add command \
        \
        -command {# TODO: Your menu handler here
global fileName
# ./pns_utility UTL_CMD = query_eposdb UTL_HOST = pnsmos

if { ![ file exist $fileName ] } {
set fowner [file attributes [file dirname $::argv0] -owner]
set cmd [concat touch $fileName \; echo "#File Format:" > $fileName \; echo "#Version_ID               Path                        #Comment" >> $fileName \; echo "#2011.2           /apps/PDGM/Paradigm-2011.2/Applications         #Example setup" >> $fileName \; gedit $fileName]
puts "Edit: owner:$fowner cmd:$cmd"
set result [run_as $fowner $cmd ]
} else {
set fowner [file attributes $fileName -owner]
puts "Edit: owner:$fowner cmd:gedit $fileName"
set result [run_as $fowner "gedit $fileName" ]
}
puts "RES: $result"
init $::argc $::argv                                                                                                                                     
main $::argc $::argv                                                                                                                                     

#puts $result} \
        -label {Edit Software versions list's file} 
    $top.lab43.men46.m add separator \
        
    $top.lab43.men46.m add command \
        \
        -command {# TODO: Your menu handler here
# TODO: Your menu handler here
pgenv
global cmd_env
global PNS_dir

if { [file exist "$PNS_dir/pns_config"] } {
set cmd "$PNS_dir/pns_config"
} else {
set cmd "$PNS_dir/pns_manager"
}
set result [run_as_admin $cmd\& ]} \
        -label {PNS Control Panel (PgAdmin)} 
    $top.lab43.men46.m add command \
        \
        -command {# TODO: Your menu handler here
pgenv
global cmd_env
global PNS_dir

if { [file exist "$PNS_dir/pns_config"] } {
set cmd "$PNS_dir/pns_config"
} else {
set cmd "$PNS_dir/pns_manager"
}
set result [run_as_dbadmin $cmd\& ]} \
        -label {PNS Control Panel (EposDB)} 
    $top.lab43.men46.m add command \
        \
        -command {# TODO: Your menu handler here
pgenv
global cmd_env
global PNS_dir

if { [file exist "$PNS_dir/pns_config"] } {
set cmd "$PNS_dir/pns_config"
} else {
set cmd "$PNS_dir/pns_manager"
}
set result [run_as_user $cmd\& ]
#catch { exec $cmd } result} \
        -label {PNS Control Panel (user)} 
    $top.lab43.men46.m add separator \
        
    $top.lab43.men46.m add command \
        \
        -command {pgenv
global cmd_env
global Epos_Path

if { [file exist "$Epos_Path/bin/PG_epos_config"] } {
set cmd "$Epos_Path/bin/PG_epos_config"
} else {
set cmd "$PNS_dir/pns_manager"
}
set result [run_as_admin $cmd\& ]} \
        -label {EPOS Control Panel (PgAdmin)} 
    $top.lab43.men46.m add command \
        \
        -command {# TODO: Your menu handler here
run_as_user "PG_epos_config\&"} \
        -label {EPOS Control Panel (user)} 
    $top.lab43.men46.m add separator \
        
    $top.lab43.men46.m add command \
        \
        -command {# TODO: Your menu handler here
global Epos_Path
global PNS_dir
global PNS_host
global cmd_env
pgenv 

set pnsm_fn "$PNS_dir/pns_manager"
puts "CALL_PNSM: fn = $pnsm_fn"
if { [file exist $pnsm_fn] } {
    puts [run_as_user [concat $cmd_env\;setenv PNS_HOST $PNS_host\;$pnsm_fn]]
}} \
        -label {PNS Manager (Epos)} 
    $top.lab43.men46.m add command \
        -command show_lpm -label {PNS Manager} 
    $top.lab43.men46.m add command \
        -command show_licsync -label {Sync to Customer Licenses...} 
    label $top.lab47 \
        -activebackground #f8f8f8 -background #ffffff -borderwidth 2 \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12"] \
        -highlightcolor #ff0000 \
        -text {Created by Alexey Gritsenko (alexey.gritsenko@pdgm.com)
Paradigm Russia & CIS
Version: 1.2 (28 Jul 2006 17:43) (unsupported)} 
    vTcl:DefineAlias "$top.lab47" "Label17" vTcl:WidgetProc "Toplevel1" 1
    button $top.but44 \
        -borderwidth 1 \
        -command {# TODO: Your menu handler here
pgenv
global cmd_env
global PNS_dir
global PNS_host
global PNS_ver
global Epos_Ver
global Epos_Path
global G_PNS_host


if { [file exist $Epos_Path/bin/pg3] } {
    catch { exec /bin/csh -c "$cmd_env; $PNS_dir/pns_manager"  } result
} elseif { [file exist $Epos_Path/bin/pg4] } {
    catch { exec /bin/csh -c "$cmd_env; pg4 -pns_select -cmd=echo"  } result
} elseif { [file exist $Epos_Path/bin/pg41] } {
    catch { exec /bin/csh -c "$cmd_env; pg41 -pns_select -cmd=echo"  } result
} elseif { [file exist $Epos_Path/bin/pgstart] } {
    catch { exec /bin/csh -c "$cmd_env; pgstart -pns_select -cmd=echo"  } result
} elseif { [file exist $Epos_Path/../site/bin/geolog6_env.tcl] } {
    set cmd_ [concat xterm -T 'Input PNS server name' -e "/bin/bash -c 'echo Input PNS server name:\;read PGL_pns_user_input \; set | grep PGL_pns_user_input | grep -v BASH | grep -v _= > ~/.PGLtmp'" \; cat ~/.PGLtmp]
    catch { exec /bin/csh -c $cmd_ } result
    puts "Select_PNS: $result"
    set num [regexp {PGL_pns_user_input='*(\S+)'*} $result -> g_pns]
    puts "Select_PNS: $g_pns"
    set ::env(PNS_HOST) $g_pns
    puts "Select_PNS: $env(PNS_HOST)"
    set G_PNS_host $g_pns
} else { set result "unable to select PNS"}

set PNS_host [get_pns_host]
set PNS_dir [get_pns_path $PNS_host]
.top43.lab43.men44 configure -text "$Epos_Ver @ $PNS_host"
puts "PNS: $PNS_host @ $PNS_dir ($PNS_ver)"
set_admin_sens
puts $result} \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12 -weight bold"] \
        -text {Select PNS...} 
    vTcl:DefineAlias "$top.but44" "Button1" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.but44 "$top.but44 Button $top all _vTclBalloon"
    bind $top.but44 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select another PNS server suitable for selected version}
    }
    button $top.but48 \
        -borderwidth 1 -command {run_as_user "PPM"} \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12 -weight bold"] \
        -text {Product Manager} 
    vTcl:DefineAlias "$top.but48" "Button2" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.but48 "$top.but48 Button $top all _vTclBalloon"
    bind $top.but48 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run PPM to select Products you want to use in your Epos Session}
    }
    button $top.but45 \
        -borderwidth 1 -command {save_last_ver;exit} \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12 -weight bold"] \
        -foreground #990000 -text Exit 
    vTcl:DefineAlias "$top.but45" "Button5" vTcl:WidgetProc "Toplevel1" 1
    checkbutton $top.che44 \
        -activebackground #ffffff -background #ffffff -borderwidth 1 \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family courier -size 12"] \
        -highlightthickness 0 -selectcolor #000000 -text Debug \
        -variable Use_Shell 
    vTcl:DefineAlias "$top.che44" "Checkbutton1" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.che44 "$top.che44 Checkbutton $top all _vTclBalloon"
    bind $top.che44 <<SetBalloon>> {
        set ::vTcl::balloon::%W {All applications run in verbose console output mode (in separate XTerm window)}
    }
    menubutton $top.men49 \
        -borderwidth 1 -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12 -weight bold"] \
        -indicatoron 1 -menu "$top.men49.m" -padx 6 -pady 4 -relief raised \
        -text {Start Session...} 
    vTcl:DefineAlias "$top.men49" "Menubutton3" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.men49 "$top.men49 Menubutton $top all _vTclBalloon"
    bind $top.men49 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Start an Application or Epos Session Manager}
    }
    menu $top.men49.m \
        -disabledforeground #a2a2a2 -tearoff 0 
    $top.men49.m add command \
        \
        -command {# TODO: Your menu handler here
global Use_Shell
global Epos_binary

if { [file exist $Epos_Path/bin/pg3] } {
set cmd pg3
} elseif { [file exist $Epos_Path/bin/pg4] } {
set cmd pg4
} elseif { [file exist $Epos_Path/bin/pg41] } {
set cmd pg41
} elseif { [file exist /bin/pgstart] } {
set cmd pgstart
}
set cmd $Epos_Path/$Epos_binary
puts "CMD: $cmd"
if { $Use_Shell } {
run_as_user "$cmd -d2"
} else {
run_as_user "$cmd"
}} \
        -label Epos... 
    $top.men49.m add command \
        \
        -command {# TODO: Your menu handler here
global Epos_Path
global Geolog_binary 

if { [file exist $Epos_Path/bin/geolog] } {
set cmd_ geolog
} elseif { [file exist $Epos_Path/bin/geolog6 ] } {
set cmd_ geolog6
}
set cmd_ $Epos_Path/$Geolog_binary
global Use_Shell
if { $Use_Shell } {
run_as_user "$cmd_ -debug"
} else {
run_as_user "$cmd_"
}} \
        -label Geolog... 
    $top.men49.m add command \
        \
        -command {# TODO: Your menu handler here
global Gocad_binary
run_as_user "$Gocad_binary\&"} \
        -label Gocad... 
    $top.men49.m add command \
        \
        -command {# TODO: Your menu handler here
global SKUA_binary
run_as_user "$SKUA_binary\&"} \
        -label SKUA... 
    $top.men49.m add command \
        \
        -command pgenv\nglobal\ cmd_env\nglobal\ Epos_Path\n#set\ term_cmd\ \[concat\ xterm\ -geom\ 200x50\ -T\ \\\"\$Epos_Ver\\\"\ -n\ \\\"\$Epos_Ver\\\"\]\nset\ term_cmd\ \[concat\ \{source\}\ \$Epos_Path/bin/EchosEnv\ \\\;\ \$Epos_Path/bin/Echos\ \]\n#set\ term_cmd\ \[concat\ 'xterm\ -geom\ 200x50\ '\ \]\n#set\ shell_cmd\ \[\ concat\ \"\$cmd_env\;\ pg4\ -cmd=\$term_cmd\;\ pg41\ -cmd=\$term_cmd\;\ pg3\ -cmd=\$term_cmd\"\ \]\nputs\ \"CMD:\ \$term_cmd\"\n#puts\ \"CMD:\ \$shell_cmd\"\nif\ \{\ \[file\ exist\ \$Epos_Path/bin/pg3\]\ \}\ \{\n\ \ \ \ catch\ \{\ exec\ /bin/csh\ -c\ \"\$cmd_env\;\ pg3\ -s\ \\&\"\ \}\ result\n\ \ \ \ catch\ \{\ exec\ ls\ \$env(HOME)\ |\ grep\ Epos3_env.\ \}\ env_scr\ \n\ \ \ \ puts\ \"ENV:\ \$env_scr\"\n\ \ \ \ catch\ \{\ exec\ echo\ \"\$term_cmd\"\ >>\ \$env(HOME)/\$env_scr\ \}\ \n\ \ \ \ set\ shell_cmd\ \[concat\ \"\$cmd_env\;\ /bin/csh\ \$env(HOME)/\$env_scr\"\ \]\n\ \ \ \ set\ term_cmd\ \[concat\ \$Epos_Path/bin/focus\ \]\n\}\ elseif\ \{\ \[file\ exist\ \$Epos_Path/bin/pg4\]\ \}\ \{\n\ \ \ \ set\ term_cmd\ \[concat\ \$Epos_Path/bin/Echos\ \]\n\ \ \ \ set\ shell_cmd\ \"\$cmd_env\;Epos_Path/bin/pg4\ -cmd='\$term_cmd'\"\n\}\ else\ \{\n\ \ \ \ set\ shell_cmd\ \"\$cmd_env\;\$Epos_Path/bin/pg41\ -cmd='\$term_cmd'\"\n\}\n#catch\ \{\ exec\ /bin/csh\ -c\ \"\$shell_cmd\"\ \\&\ \}\ result\n#puts\ \"RES:\ \$result\"\nputs\ \"CMD:\ \$shell_cmd\"\nputs\ \"RES:\ \[run_as_user\ \$shell_cmd\]\"\nreturn\ \n\n#####################################################################\npgenv\nglobal\ cmd_env\nglobal\ Epos_Ver\nglobal\ PNS_host\n\nif\ \{\ \[regexp\ \{.*\[eE\]\[pP\]\[oO\]\[sS\]4.*\}\ \$Epos_Ver\ \]\ \}\ \{\nset\ env_echos\ \{\}\n\}\ else\ \{\nset\ env_echos\ \{\\\nsetenv\ PG_ARG_epos_user\ \$USER\nsetenv\ PG_TMPDIR\ /tmp\nsetenv\ PG_ARCH\ `ls\ \$PG_ROOT/arch`\nsetenv\ PG_ARCH_ROOT\ \$PG_ROOT/arch/\$PG_ARCH\nsetenv\ PG_PATH\ \$PG_ARCH_ROOT\nsetenv\ PATH\ \"\$PG_ARCH_ROOT/bin:\$PATH\"\nsetenv\ PRDM_GEO_LICENSE_FILE\ 7507@yptmos1\nsetenv\ LD_LIBRARY_PATH\ \"\$PG_ARCH_ROOT/lib:\$PG_ARCH_ROOT/lib/rtl\"\nsetenv\ LD_RUN_PATH\ \$LD_LIBRARY_PATH\nsetenv\ PG_CONFIG_PATH\ \$PG_ROOT/config\nsetenv\ PG_ONLINE_HELP\ \$PG_ROOT/Applications/doc/Echos\nsource\ \$PG_ROOT/bin/EchosEnv\n\}\n\}\nset\ env(PNS_HOST)\ \$PNS_host\nrun_as_user\ \"\$env_echos\;\ Echos&\" \
        -label Echos... 
    button $top.but43 \
        -borderwidth 1 \
        -command {pgenv
global cmd_env
#set term_cmd [concat xterm -geom 200x50 -T \"$Epos_Ver\" -n \"$Epos_Ver\"]
set term_cmd [concat cd $Epos_Path \; xterm -geom 200x50 -T $Epos_Path -n $Epos_Path]
#set shell_cmd [ concat "$cmd_env; pg4 -cmd=$term_cmd; pg41 -cmd=$term_cmd; pg3 -cmd=$term_cmd" ]
puts "CMD: $term_cmd"
#puts "CMD: $shell_cmd"
if { [file exist $Epos_Path/bin/pg3] } {
catch { exec /bin/csh -c "$cmd_env; pg3 -s \&" } result
catch { exec ls $env(HOME) | grep Epos3_env. } env_scr 
puts "ENV: $env_scr"
catch { exec echo "$term_cmd" >> $env(HOME)/$env_scr } 
set shell_cmd [concat "$cmd_env; /bin/csh $env(HOME)/$env_scr" ]
#puts "pg3: $result"
} elseif { [file exist $Epos_Path/bin/pg4] } {
#catch { exec /bin/csh -c "$cmd_env;cd $Epos_Path/bin;source pg4 -cmd=echo ; $term_cmd \&" } result
set shell_cmd "$cmd_env;pg4 -cmd='$term_cmd'"
#puts "pg4: $result"
} elseif { [file exist Epos_Path/bin/pg41]} {
#catch { exec /bin/csh -c "$cmd_env;cd $Epos_Path/bin;source pg41 -cmd=echo ;$term_cmd \&" } result
set shell_cmd "$cmd_env;pg41 -override_rtvr  -cmd='$term_cmd'"
#puts "pg41: $result"
} else {
    set shell_cmd "$cmd_env;$term_cmd"
}
#catch { exec /bin/csh -c "$cmd_env;$term_cmd \&" \& } result
catch { exec /bin/csh -c "setenv PG_OVERRIDE_RTVR 1;$shell_cmd" \& } result
puts "CMD: $shell_cmd"
puts "RES: $result"
#run_as_user $shell_cmd} \
        -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12 -weight bold"] \
        -text {Run Shell...} 
    vTcl:DefineAlias "$top.but43" "Button3" vTcl:WidgetProc "Toplevel1" 1
    bindtags $top.but43 "$top.but43 Button $top all _vTclBalloon"
    bind $top.but43 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open new XTerm window with environment set to selected version}
    }
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab43 \
        -in $top -anchor n -expand 1 -fill both -side top 
    pack $top.lab43.lab43 \
        -in $top.lab43 -anchor s -expand 0 -fill none -side left 
    pack $top.lab43.men44 \
        -in $top.lab43 -anchor s -expand 1 -fill x -side bottom 
    pack $top.lab43.but44 \
        -in $top.lab43 -anchor ne -expand 0 -fill none -side right 
    place $top.lab43.men46 \
        -in $top.lab43 -x -5 -y 0 -width 167 -height 18 -anchor nw \
        -bordermode ignore 
    pack $top.lab47 \
        -in $top -anchor s -expand 0 -fill both -side bottom 
    pack $top.but44 \
        -in $top -anchor center -expand 1 -fill none -side left 
    pack $top.but48 \
        -in $top -anchor center -expand 1 -fill none -side left 
    pack $top.but45 \
        -in $top -anchor center -expand 0 -fill none -side right 
    pack $top.che44 \
        -in $top -anchor center -expand 1 -fill none -side right 
    pack propagate $top.men49 0
    grid propagate $top.men49 0
    pack $top.men49 \
        -in $top -anchor center -expand 1 -fill none -side right 
    pack $top.but43 \
        -in $top -anchor center -expand 1 -fill none -side left 

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top44 {base} {
    if {$base == ""} {
        set base .top44
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -highlightcolor black 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 742x863+0+152; update
    wm maxsize $top 3185 1170
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Sync Licenses"
    vTcl:DefineAlias "$top" "Toplevel2" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    frame $top.fra53 \
        -borderwidth 2 -relief groove -height 407 -width 436 
    vTcl:DefineAlias "$top.fra53" "Frame1" vTcl:WidgetProc "Toplevel2" 1
    set site_3_0 $top.fra53
    frame $site_3_0.fra83 \
        -relief groove -height 126 -width 125 
    vTcl:DefineAlias "$site_3_0.fra83" "Frame4" vTcl:WidgetProc "Toplevel2" 1
    set site_4_0 $site_3_0.fra83
    button $site_4_0.cpd84 \
        -command show_licsync -disabledforeground #a2a2a2 -relief flat \
        -text {Current License Server(s):} 
    vTcl:DefineAlias "$site_4_0.cpd84" "Button6" vTcl:WidgetProc "Toplevel2" 1
    bindtags $site_4_0.cpd84 "$site_4_0.cpd84 Button $top all _vTclBalloon"
    bind $site_4_0.cpd84 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Click to refresh servers list...}
    }
    scrollbar $site_4_0.cpd86 \
        -command {Lic_Serv_list yview} 
    vTcl:DefineAlias "$site_4_0.cpd86" "Scrollbar2" vTcl:WidgetProc "Toplevel2" 1
    listbox $site_4_0.cpd85 \
        -background white -disabledforeground #a2a2a2 -exportselection 0 \
        -font [vTcl:font:getFontFromDescr "-family courier -size 12"] \
        -height 5 -width 225 -yscrollcommand {Scrollbar2 set} \
        -listvariable "$top\::lis57" 
    vTcl:DefineAlias "$site_4_0.cpd85" "Lic_Serv_list" vTcl:WidgetProc "Toplevel2" 1
    bind $site_4_0.cpd85 <<ListboxSelect>> {
        set_list_Serv_sel %W
    }
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor w -expand 0 -fill none -side top 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor e -expand 0 -fill y -side right 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor e -expand 0 -fill both -side right 
    button $site_3_0.but58 \
        -borderwidth 1 \
        -command {global Add_Lic_Srv
global LicSrvList

catch { exec ping $Add_Lic_Srv -c1 -W 1 } ping_res
#puts "PING: $Add_Lic_Srv : $ping_res"
set srverr ""
if {  [string length $Add_Lic_Srv] < 2 } { set srverr "empty name" }
if {  [lsearch $LicSrvList $Add_Lic_Srv] > -1 } { set srverr "already in the list" }
if {  [regexp {1 received} $ping_res] == 0 } { set srverr "no ping" }

if {  [string length $srverr] == 0 } {
        Lic_Serv_list insert end $Add_Lic_Srv
        lappend LicSrvList $Add_Lic_Srv
} else {
     tk_messageBox -parent .top44 -icon error -title "Error" -message "Unable to add host \[$Add_Lic_Srv\]\n($srverr)"
}} \
        -default disabled -disabledforeground #a2a2a2 -state disabled \
        -text Add 
    vTcl:DefineAlias "$site_3_0.but58" "add_srv_but" vTcl:WidgetProc "Toplevel2" 1
    button $site_3_0.but59 \
        -borderwidth 1 \
        -command [list vTcl:DoCmdOption $site_3_0.but59 {global widget
global FeatList
global Srv_Lic_lines

set types {
    {{License Files}       {.lic .dat}        }
    {{All Files}        *             }
}
set lic_file [ tk_getOpenFile -filetypes $types -parent .top44 -initialdir $env(HOME) -title "Select Customer's License file to sync with..." ]
puts "LIC_FILE: $lic_file"
    if { [file exist $lic_file] } {
    ### ### reading license file's features
    set FeatList {}
    Features_list delete 0 end
    SaveLic configure -state disabled 
    RestartLic configure -state disabled 
    set ver_lines {}
    catch {set v_file [open $lic_file r]} openres
    if { [regexp {^file[0123456789]*} $openres ] } {
        set contents [read -nonewline $v_file]     
        close $v_file 
        set ver_lines [split $contents "\n"] 
        set Srv_Lic_lines $ver_lines
        #parse LICENSE versions file
        set hdr 1
        set lfheader {}
        foreach ver_line  $ver_lines {
#            regexp {^[ \t]*([^#]\S*)[\t ]+(/\S*)[\t ]*(.*)} $ver_line -> ver path comm ]
            set nmatch [ regexp {[FI][EN][AC][TR][UE][RM]E\S* (\S*) \S* \S* (\S*) (\S*)} $ver_line -> ftname ftdate ftnum]
            if { $nmatch } {
            #puts "LINE: $ver_line"
                set hdr 0
                lappend FeatList $ftname
                Features_list insert end [format "%-33s count:%-5s  expires %s" $ftname $ftnum $ftdate]
            }
            if { $hdr } {
                append lfheader $ver_line\n
            }
        }
        Lic_info configure -text "License file header:\n$lfheader"    
    }
    }
if { [llength $FeatList] }  { SelSyncFile configure -state normal } { SelSyncFile configure -state disabled }
set_ent_Search [Search_feat get]}] \
        -disabledforeground #a2a2a2 -text {Load Full/Owned license...} 
    vTcl:DefineAlias "$site_3_0.but59" "Button2" vTcl:WidgetProc "Toplevel2" 1
    bindtags $site_3_0.but59 "$site_3_0.but59 Button $top all _vTclBalloon"
    bind $site_3_0.but59 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Read features list from license file...}
    }
    entry $site_3_0.ent44 \
        -background white -disabledforeground #a2a2a2 -insertbackground black \
        -textvariable "$top\::ent44" -validate key \
        -validatecommand {set_ent_AddSrv %P} 
    vTcl:DefineAlias "$site_3_0.ent44" "add_srv_ent" vTcl:WidgetProc "Toplevel2" 1
    label $site_3_0.lab45 \
        -disabledforeground #a2a2a2 -text {Server Name:} 
    vTcl:DefineAlias "$site_3_0.lab45" "add_srv_lab" vTcl:WidgetProc "Toplevel2" 1
    pack $site_3_0.fra83 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.but58 \
        -in $site_3_0 -anchor se -expand 0 -fill none -side right 
    pack $site_3_0.but59 \
        -in $site_3_0 -anchor sw -expand 0 -fill none -side left 
    pack $site_3_0.ent44 \
        -in $site_3_0 -anchor e -expand 0 -fill none -side right 
    pack $site_3_0.lab45 \
        -in $site_3_0 -anchor e -expand 0 -fill none -side right 
    frame $top.fra54 \
        -relief groove -height 101 -width 566 
    vTcl:DefineAlias "$top.fra54" "Frame2" vTcl:WidgetProc "Toplevel2" 1
    set site_3_0 $top.fra54
    frame $site_3_0.fra74 \
        -borderwidth 2 -relief groove -height 210 -width 125 
    vTcl:DefineAlias "$site_3_0.fra74" "Frame3" vTcl:WidgetProc "Toplevel2" 1
    set site_4_0 $site_3_0.fra74
    label $site_4_0.cpd76 \
        -disabledforeground #a2a2a2 -text {Server's Features list:} 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label1" vTcl:WidgetProc "Toplevel2" 1
    frame $site_4_0.fra48 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra48" "Frame5" vTcl:WidgetProc "Toplevel2" 1
    set site_5_0 $site_4_0.fra48
    label $site_5_0.lab45 \
        -disabledforeground #a2a2a2 -font fixed -height 9 -justify left \
        -text {Product:N\A
Description:N\A


} 
    vTcl:DefineAlias "$site_5_0.lab45" "Feat_detail" vTcl:WidgetProc "Toplevel2" 1
    button $site_5_0.but49 \
        -borderwidth 1 \
        -command {Features_list selection set 0 end
set fsel [Features_list curselection]
if { [llength $fsel] } { 
    RestartLic configure -state normal 
    SaveLic configure -state normal 
} else {
    RestartLic configure -state disabled
    SaveLic configure -state disabled
}} \
        -disabledforeground #a2a2a2 -text {Select all} 
    vTcl:DefineAlias "$site_5_0.but49" "SelAllFeat" vTcl:WidgetProc "Toplevel2" 1
    button $site_5_0.but50 \
        -borderwidth 1 \
        -command {Features_list selection clear 0 end
set fsel [Features_list curselection]
if { [llength $fsel] } { 
    RestartLic configure -state normal 
    SaveLic configure -state normal 
} else {
    RestartLic configure -state disabled
    SaveLic configure -state disabled
}} \
        -disabledforeground #a2a2a2 -text {Clear selection} 
    vTcl:DefineAlias "$site_5_0.but50" "ClearSelFeat" vTcl:WidgetProc "Toplevel2" 1
    label $site_5_0.lab52 \
        -disabledforeground #a2a2a2 -text Search: 
    vTcl:DefineAlias "$site_5_0.lab52" "SearchLab" vTcl:WidgetProc "Toplevel2" 1
    entry $site_5_0.ent53 \
        -background white -disabledforeground #a2a2a2 -exportselection 0 \
        -insertbackground black -textvariable "$top\::ent53" -validate key 
    vTcl:DefineAlias "$site_5_0.ent53" "Search_feat" vTcl:WidgetProc "Toplevel2" 1
    bindtags $site_5_0.ent53 "$site_5_0.ent53 Entry $top all _vTclBalloon"
    bind $site_5_0.ent53 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Type in feature name here to find it in the list...}
    }
    label $site_5_0.lab44 \
        -disabledforeground #a2a2a2 -text {found cont} 
    vTcl:DefineAlias "$site_5_0.lab44" "Found_lab" vTcl:WidgetProc "Toplevel2" 1
    pack $site_5_0.lab45 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side bottom 
    pack $site_5_0.but49 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.but50 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.lab52 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent53 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.lab44 \
        -in $site_5_0 -anchor e -expand 0 -fill none -side right 
    scrollbar $site_4_0.scr81 \
        -command {Features_list yview} 
    vTcl:DefineAlias "$site_4_0.scr81" "Scrollbar1" vTcl:WidgetProc "Toplevel2" 1
    listbox $site_4_0.lis75 \
        -background white -disabledforeground #a2a2a2 -exportselection 0 \
        -font [vTcl:font:getFontFromDescr "-family courier -size 12"] \
        -height 15 -selectmode extended -takefocus {} -width 225 \
        -yscrollcommand {Scrollbar1 set} -listvariable "$top\::lis75" 
    vTcl:DefineAlias "$site_4_0.lis75" "Features_list" vTcl:WidgetProc "Toplevel2" 1
    bind $site_4_0.lis75 <<ListboxSelect>> {
        set_list_Feat_sel %W
    }
    bind $site_4_0.lis75 <Motion> {
        set_list_Feat_click %W %x %y
    }
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor nw -expand 0 -fill none -side top 
    pack $site_4_0.fra48 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_4_0.scr81 \
        -in $site_4_0 -anchor e -expand 1 -fill y -side right 
    pack $site_4_0.lis75 \
        -in $site_4_0 -anchor e -expand 1 -fill both -side right 
    frame $site_3_0.fra44 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra44" "Frame6" vTcl:WidgetProc "Toplevel2" 1
    set site_4_0 $site_3_0.fra44
    label $site_4_0.cpd45 \
        -disabledforeground #a2a2a2 -height 12 -justify left \
        -text {License file info:} 
    vTcl:DefineAlias "$site_4_0.cpd45" "Lic_info" vTcl:WidgetProc "Toplevel2" 1
    scrollbar $site_4_0.scr47 \
        -command {LicLogBox yview} 
    vTcl:DefineAlias "$site_4_0.scr47" "LicLogScroll" vTcl:WidgetProc "Toplevel2" 1
    listbox $site_4_0.lis46 \
        -background white -disabledforeground #a2a2a2 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12"] \
        -selectmode extended -yscrollcommand {LicLogScroll set} \
        -listvariable "$top\::lis46" 
    vTcl:DefineAlias "$site_4_0.lis46" "LicLogBox" vTcl:WidgetProc "Toplevel2" 1
    bindtags $site_4_0.lis46 "$site_4_0.lis46 Listbox $top all _vTclBalloon"
    bind $site_4_0.lis46 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select Lines to copy them to clipboard...}
    }
    button $site_4_0.but43 \
        -borderwidth 0 -command {set_list_Log_sel LicLogBox} \
        -disabledforeground #a2a2a2 -justify right \
        -text {         Running Server log:} 
    vTcl:DefineAlias "$site_4_0.but43" "LicLogUpd" vTcl:WidgetProc "Toplevel2" 1
    bindtags $site_4_0.but43 "$site_4_0.but43 Button $top all _vTclBalloon"
    bind $site_4_0.but43 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Click here to re-read running server log file}
    }
    scrollbar $site_4_0.scr45 \
        -command {LogDateBox yview} 
    vTcl:DefineAlias "$site_4_0.scr45" "LogDateScroll" vTcl:WidgetProc "Toplevel2" 1
    frame $site_4_0.fra44 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra44" "Frame7" vTcl:WidgetProc "Toplevel2" 1
    set site_5_0 $site_4_0.fra44
    label $site_5_0.lab45 \
        -disabledforeground #a2a2a2 -text {Filter by:} 
    vTcl:DefineAlias "$site_5_0.lab45" "LogFiltLab" vTcl:WidgetProc "Toplevel2" 1
    menubutton $site_5_0.men46 \
        -borderwidth 1 -disabledforeground #a2a2a2 -indicatoron 1 \
        -menu "$site_5_0.men46.m" -padx 5 -pady 4 -relief raised -text Date 
    vTcl:DefineAlias "$site_5_0.men46" "LogFbut" vTcl:WidgetProc "Toplevel2" 1
    menu $site_5_0.men46.m \
        -disabledforeground #a2a2a2 -tearoff 0 
    $site_5_0.men46.m add command \
        -command {set_log_lists 1} -label Date 
    $site_5_0.men46.m add command \
        -command {set_log_lists 2} -label User 
    $site_5_0.men46.m add command \
        -command {set_log_lists 3} -label Host 
    pack $site_5_0.lab45 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.men46 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    listbox $site_4_0.lis44 \
        -background white -disabledforeground #a2a2a2 -exportselection 0 \
        -font [vTcl:font:getFontFromDescr "-family helvetica -size 12"] \
        -height 7 -yscrollcommand {LogDateScroll set} \
        -listvariable "$top\::lis44" 
    vTcl:DefineAlias "$site_4_0.lis44" "LogDateBox" vTcl:WidgetProc "Toplevel2" 1
    pack $site_4_0.cpd45 \
        -in $site_4_0 -anchor w -expand 0 -fill none -side left 
    pack $site_4_0.scr47 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side right 
    pack $site_4_0.lis46 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side right 
    pack $site_4_0.but43 \
        -in $site_4_0 -anchor w -expand 0 -fill x -side top 
    pack $site_4_0.scr45 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side right 
    pack $site_4_0.fra44 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.lis44 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side right 
    button $site_3_0.but62 \
        -borderwidth 1 \
        -command {global FeatList
global User_LicFile

set types {
    {{License Files}       {.lic .dat}        }
    {{All Files}        *             }
}
set User_LicFile [ tk_getOpenFile -filetypes $types -parent .top44 -initialdir $env(HOME) -title "Select Customer's License file to sync with..." ]
Features_list selection clear 0 end
set feat_mathes {}
if { [file exist $User_LicFile ] } {
    set ver_lines {}
    catch {set v_file [open $User_LicFile r]} openres
    if { [regexp {^file[0123456789]*} $openres ] } {
    set contents [read -nonewline $v_file]     
    close $v_file 
    set ver_lines [split $contents "\n"] 
         foreach ver_line  $ver_lines {
        #               regexp {^[ \t]*([^#]\S*)[\t ]+(/\S*)[\t ]*(.*)} $ver_line -> ver path comm ]
            set nmatch [ regexp {[FI][EN][AC][TR][UE][RM]E\S* (\S*) \S* \S* (\S*) (\S*)} $ver_line -> ftname ftdate ftnum]
            if { $nmatch } {
            #puts "LINE: $ver_line"
            set found_lic [lsearch -exact $FeatList $ftname]
            if { $found_lic >= 0 } {    
                puts "LIC_MATCH: $ftname"
                Features_list selection set $found_lic
            }
            }
        }
    }
}
set fsel [Features_list curselection]
if { [llength $fsel] } {
    RestartLic configure -state normal 
    SaveLic configure -state normal 
} else {
    RestartLic configure -state disabled
    SaveLic configure -state disabled
}} \
        -disabledforeground #a2a2a2 -state disabled \
        -text {Customer's License...} 
    vTcl:DefineAlias "$site_3_0.but62" "SelSyncFile" vTcl:WidgetProc "Toplevel2" 1
    bindtags $site_3_0.but62 "$site_3_0.but62 Button $top all _vTclBalloon"
    bind $site_3_0.but62 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Read Customer's license file features and selects them in list above...}
    }
    button $site_3_0.but63 \
        -borderwidth 1 \
        -command global\ LicSrv\nglobal\ Srv_user\nglobal\ Srv_Lic_file\nglobal\ fileName\n\nif\ \{\ \[string\ length\ \$LicSrv\]\ \}\ \{\n\ \ \ \ ###\ reading\ license\ server\ script\n\ \ \ \ set\ cmd\ \[concat\ ps\ -do\ cmd\ |\ grep\ lmgrd\ |\ grep\ -v\ grep\]\n\ \ \ \ set\ adm_user\ \[file\ attributes\ \$fileName\ -owner\]\n\ \ \ \ set\ error_ssh\ \[get_remote_cmd_result\ \$LicSrv\ \$cmd\]\n\ \ \ \ \n\ \ \ \ #\ getting\ ligrd\ and\ lmutil\ binaries\ path\n\ \ \ \ set\ bin_path\ \{\}\n\ \ \ \ set\ num\ \[regexp\ \{(/.*)/lmgrd\}\ \$error_ssh\ ->\ bin_path\]\n\ \ \ \ #\ if\ lmgd\ is\ not\ currently\ running,\ look\ into\ PG_lmgrd_startup_script\n\ \ \ \ if\ \{\ \$num\ <1\ \}\ \{\n\ \ \ \ \ \ \ \ puts\ \"LIC:\ no\ running\ lmgrd\ found\ on\ \$LicSrv\"\n\ \ \ \ \ \ \ \ set\ cmd\ \[concat\ cat\ /etc/init.d/PG_lmgrd_startup_script\ \]\n\ \ \ \ \ \ \ \ set\ error_ssh\ \[get_remote_cmd_result\ \$LicSrv\ \$cmd\ \]\n\ \ \ \ \ \ \ \ #puts\ \"LIC_SSH:\ \$error_ssh\"\n\ \ \ \ \ \ \ \ set\ lines\ \[split\ \$error_ssh\ \"\\n\"\]\n\ \ \ \ \ \ \ \ foreach\ line\ \$lines\ \{\n\ \ \ \ \ \ \ \ \ \ \ \ set\ num\ \[\ regexp\ \{\"(/.*?)lmgrd\}\ \$line\ ->\ cmd_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ if\ \{\ \$num\ \}\ \{set\ bin_path\ \$cmd_\}\n\ \ \ \ \ \ \ \ \ \ \ \ set\ num\ \[\ regexp\ \{\[-\]\ (\\S*)\ \[-\]\}\ \$line\ ->\ user_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ if\ \{\ \$num\ &&\ \[string\ length\ \$Srv_user\]\ <1\ \}\ \{set\ Srv_user\ \$user_\}\n\ \ \ \ \ \ \ \ \ \ \ \ set\ num\ \[\ regexp\ \{lmgrd\\W+\[-\]c\\W+(/.*).\"\\W+>>\}\ \$line\ ->\ lic_file_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ if\ \{\ \$num\ &&\ \[string\ length\ \$Srv_Lic_file\]\ <1\ \}\ \{set\ Srv_Lic_file\ \$lic_file_\}\n\ \ \ \ \ \ \ \ \ \ \ \ puts\ \"LIC:LINE:\ \$line\"\n\ \ \ \ \ \ \ \ \}\n\ \ \ \ \}\ else\ \{\n\ \ \ \ \ \ \ \ puts\ \"LC:\ lmgrd\ is\ running\ on\ \$LicSrv\"\n\ \ \ \ \ \ \ \ #\ getting\ current\ license\ file\ path\n\ \ \ \ \ \ \ \ set\ Srv_Lic_file\ \{\}\n\ \ \ \ \ \ \ \ set\ num\ \[regexp\ \{.*lmgrd\ -c\ (.*)\}\ \$error_ssh\ ->\ lic_file_\]\n\ \ \ \ \ \ \ \ if\ \{\ \$num\ \}\ \{\n\ \ \ \ \ \ \ \ \ \ \ \ set\ lic_file\ \[string\ map\ \{\ \{\ \}\ \{\\\ \}\ \ \}\ \$lic_file_\]\n\ \ \ \ \ \ \ \ \ \ \ \ set\ Srv_Lic_file\ \$lic_file\n\ \ \ \ \ \ \ \ \ \ \ \ puts\ \"LIC_FILE:\ \$lic_file\"\n\ \ \ \ \ \ \ \ \}\n\ \ \ \ \}\ \ \ \ \n\ \ \ \ #\ writing\ license\ file\ for\ server\ restart\n\ \ \ \ set\ custom_lic_file\ /tmp/license.dat\n\ \ \ \ save_feat_file\ \$custom_lic_file\ \"Saved\ by\ PGL\ for\ Restarting\ \$LicSrv\ \"\n\ \ \ \ \n\ \ \ \ puts\ \"LIC_PATH:\ \$bin_path\"\n\ \ \ \ puts\ \"LIC_FILE:\ \$Srv_Lic_file\"\n\ \ \ \ puts\ \"LIC_SRV:\ \$LicSrv\"\n\ \ \ \ puts\ \"LIC_SRV_USER:\ \$Srv_user\"\n\ \ \ \ \ncatch\ \{\ tk_messageBox\ -parent\ .top44\ -icon\ warning\ -type\ yesno\ -title\ \"Restart\ License\ server?\"\ -message\ \\\n\"Are\ you\ sure\ to\ restart\ License\ server\ '\$LicSrv'?\\n\\npassword\ could\ be\ required...\\n\\nOperation\ will\ take\ about\ 30\ secs\ to\ complete...\"\ \}\ ans\n\ \ \ \ \nif\ \{\ \[string\ equal\ \$ans\ \"yes\"\ \]\ \}\ \{\n\ \ \ \ if\ \{\ \[string\ length\ \$bin_path\]\ &&\ \[string\ length\ \$Srv_Lic_file\]\ \ &&\ \[string\ length\ \$LicSrv\]\ \}\ \{\n\ \ \ \ \ \ \ \ if\ \{\ \[file\ exist\ \[file\ dirname\ \$Srv_Lic_file\]\ \]\ \}\ \{\ set\ lic_file_\ \[file\ dirname\ \$Srv_Lic_file\]/PGL_license.lic\ \}\ \{set\ lic_file_\ ~/PGL_license.lic\}\n\ \ \ \ \ \ \ \ set\ lic_cmd\ \[concat\ cp\ \$custom_lic_file\ \$lic_file_\ \]\n\ \ \ \ \ \ \ \ run_as\ \$Srv_user\ \$lic_cmd\n\ \ \ \ \ \ \ \ catch\ \{\ exec\ \[rm\ -f\ \$custom_lic_file\]\ \}\n\ \ \ \ \ \ \ \ set\ lic_cmd\ \[concat\ \$bin_path/lmutil\ lmdown\ -q\ -c\ \$Srv_Lic_file\ \\\;\ sleep\ 5\ \\\;\ \$bin_path/lmgrd\ -c\ \$lic_file_\ >\\&\ \$lic_file_.log\ \\\;\ sleep\ 20\ \]\n\ \ \ \ \ \ \ \ #puts\ \"EXTR_CMD:\ <\$user>\ <\$cmd>\ @\ \$line\"\n\ \ \ \ \ \ \ \ puts\ \"EXTR_CMD:\ \$lic_cmd\"\n\ \ \ \ \ \ \ \ get_remote_cmd_result_as\ \$Srv_user\ \$LicSrv\ \$lic_cmd\n\ \ \ \ \ \ \ \ set_list_Serv_sel\ Lic_Serv_list\n\ \ \ \ \}\ else\ \{\n\ \ \ \ \ \ \ \ puts\ \"LIC:\ Could\ not\ collect\ required\ info:\ <\$bin_path>\ <\$Srv_Lic_file>\ <LicSrv>\"\n\ \ \ \ \}\n\}\n\ \ \ \ \n\} \
        -disabledforeground #a2a2a2 -state disabled -text {Restart Server...} 
    vTcl:DefineAlias "$site_3_0.but63" "RestartLic" vTcl:WidgetProc "Toplevel2" 1
    bindtags $site_3_0.but63 "$site_3_0.but63 Button $top all _vTclBalloon"
    bind $site_3_0.but63 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Restarts selected License server with selected features only...}
    }
    button $site_3_0.but67 \
        -borderwidth 1 \
        -command {global Srv_Lic_lines
global FeatList

set types {
    {{License Files}       {.lic .dat}        }
    {{All Files}        *             }
}
set New_LicFile [ tk_getSaveFile -defaultextension .lic -filetypes $types -parent .top44 -initialdir $env(HOME) -title "Define license file to save selected features..." ]
save_feat_file $New_LicFile "Saved as new by PGL..."
return} \
        -disabledforeground #a2a2a2 -state disabled -text {Save as..} 
    vTcl:DefineAlias "$site_3_0.but67" "SaveLic" vTcl:WidgetProc "Toplevel2" 1
    bindtags $site_3_0.but67 "$site_3_0.but67 Button $top all _vTclBalloon"
    bind $site_3_0.but67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Saves a new license file with selected features only...}
    }
    button $site_3_0.but43 \
        -borderwidth 1 \
        -command global\ LicSrv\nglobal\ Srv_user\nglobal\ Srv_Lic_file\nglobal\ fileName\n\nset\ user\ \{\}\nset\ bin_path\ \{\}\nset\ log_file\ \{\}\nif\ \{\ \[string\ length\ \$LicSrv\]\ \}\ \{\n\ \ \ \ \ \ \ \ puts\ \"LIC:\ no\ running\ lmgrd\ found\ on\ \$LicSrv\"\n\ \ \ \ \ \ \ \ set\ cmd\ \[concat\ cat\ /etc/init.d/PG_lmgrd_startup_script\ \]\n\ \ \ \ \ \ \ \ set\ error_ssh\ \[get_remote_cmd_result\ \$LicSrv\ \$cmd\ \]\n\ \ \ \ \ \ \ \ #puts\ \"LIC_SSH:\ \$error_ssh\"\n\ \ \ \ \ \ \ \ set\ lines\ \[split\ \$error_ssh\ \"\\n\"\]\n\ \ \ \ \ \ \ \ foreach\ line\ \$lines\ \{\n\ \ \ \ \ \ \ \ \ \ \ \ set\ num\ \[\ regexp\ \{\"(/.*?)lmgrd\}\ \$line\ ->\ cmd_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ if\ \{\ \$num\ \}\ \{set\ bin_path\ \$cmd_\}\n\ \ \ \ \ \ \ \ \ \ \ \ set\ num\ \[\ regexp\ \{\[-\]\ (\\S*)\ \[-\]\}\ \$line\ ->\ user_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ if\ \{\ \$num\ &&\ \[string\ length\ \$Srv_user\]\ <1\ \}\ \{set\ Srv_user\ \$user_\}\n#\ \ \ \ \ \ \ \ \ \ \ \ set\ num\ \[\ regexp\ \{lmgrd\\W+\[-\]c\\W+(/.*).\"\\W+>>\}\ \$line\ ->\ lic_file_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ set\ num\ \[\ regexp\ \{lmgrd\\s+\[-\]c\\s+(\\S+)\\s+>>\}\ \$line\ ->\ lic_file_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ if\ \{\ \$num\ \}\ \{set\ Srv_Lic_file\ \$lic_file_\}\n\ \ \ \ \ \ \ \ \ \ \ \ set\ num\ \[\ regexp\ \{\\>\\>\\W*(\[\$/\]\\S+)\\W*\\\"\}\ \$line\ ->\ log_file_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ if\ \{\ \$num\ \}\ \{\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ set\ uhd\ \[string\ first\ \{\$userHomeDir\}\ \$log_file_\ \]\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ puts\ \"UHD:\ \$uhd\"\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ if\ \{\ \$uhd\ >=\ 0\ \}\ \{\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ puts\ \"REPL:\ \$log_file_\"\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ set\ log_file_\ \[\ string\ replace\ \$log_file_\ \$uhd\ 11\ \ \$::env(HOME)\]\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ puts\ \"REPL:\ \$log_file_\"\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \}\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ set\ log_file\ \$log_file_\n\ \ \ \ \ \ \ \ \ \ \ \ \}\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \n\ \ \ \ \ \ \ \ \ \ \ \ puts\ \"LIC:LINE:\ num=\$num\ \$line\"\n\ \ \ \ \ \ \ \ \}\n\ \ \ \ puts\ \"LIC_PATH:\ \$bin_path\"\n\ \ \ \ puts\ \"LIC_FILE:\ \$Srv_Lic_file\"\n\ \ \ \ puts\ \"LIC_SRV:\ \$LicSrv\"\n\ \ \ \ puts\ \"LIC_LOG:\ \$log_file\"\n\ \ \ \ \ncatch\ \{\ tk_messageBox\ -parent\ .top44\ -icon\ warning\ -type\ yesno\ -title\ \"Restart\ License\ server?\"\ -message\ \\\n\"Are\ you\ sure\ to\ restart\ License\ server\ '\$LicSrv'?\\n\\npassword\ could\ be\ required...\\n\\nOperation\ will\ take\ about\ 30\ secs\ to\ complete...\"\ \}\ ans\n\ \ \ \ \nif\ \{\ \[string\ equal\ \$ans\ \"yes\"\ \]\ \}\ \{\n\ \ \ \ if\ \{\ \[string\ length\ \$bin_path\]\ &&\ \[string\ length\ \$Srv_Lic_file\]\ \ &&\ \[string\ length\ \$LicSrv\]\ \}\ \{\n\ \ \ \ \ \ \ \ set\ lic_cmd\ \[concat\ \$bin_path/lmutil\ lmdown\ -q\ -c\ \$Srv_Lic_file\ \\\;\ sleep\ 5\ \\\;\ \$bin_path/lmgrd\ -c\ \$Srv_Lic_file\ >>&\ \$log_file\\\;\ sleep\ 20\ \]\n\ \ \ \ \ \ \ \ puts\ \"EXTR_CMD:\ \$lic_cmd\"\n\ \ \ \ \ \ \ \ get_remote_cmd_result_as\ \$Srv_user\ \$LicSrv\ \$lic_cmd\n\ \ \ \ \ \ \ \ set_list_Serv_sel\ Lic_Serv_list\n\ \ \ \ \}\ else\ \{\n\ \ \ \ \ \ \ \ puts\ \"LIC:\ Could\ not\ collect\ required\ info:\ <\$bin_path>\ <\$Srv_Lic_file>\ <LicSrv>\"\n\ \ \ \ \}\n\}\n\ \ \ \ \n\} \
        -disabledforeground #a2a2a2 \
        -text {Reset License Server to default...} 
    vTcl:DefineAlias "$site_3_0.but43" "PGLMrestart" vTcl:WidgetProc "Toplevel2" 1
    button $site_3_0.but44 \
        -borderwidth 1 \
        -command {global Epos_Path

catch { exec /bin/csh -c "cat $Epos_Path/bin/PG_epos_config" } err3
set err2 [regsub -line {site_config.tcl} $err3 "/cpl/tcl/7_admin_licmgr.tcl"]
cd $Epos_Path/bin 
catch { $Epos_Path/bin/pg41 -no_license_check -no_pns_select -cmd="$err2" } err1
puts $err1} \
        -disabledforeground #a2a2a2 -state disabled \
        -text {Epos License Manager...} 
    vTcl:DefineAlias "$site_3_0.but44" "Button1" vTcl:WidgetProc "Toplevel2" 1
    pack $site_3_0.fra74 \
        -in $site_3_0 -anchor n -expand 1 -fill both -side top 
    pack $site_3_0.fra44 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_3_0.but62 \
        -in $site_3_0 -anchor n -expand 0 -fill none -side left 
    pack $site_3_0.but63 \
        -in $site_3_0 -anchor n -expand 0 -fill none -side right 
    pack $site_3_0.but67 \
        -in $site_3_0 -anchor n -expand 0 -fill none -side right 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra53 \
        -in $top -anchor n -expand 0 -fill x -side top 
    pack $top.fra54 \
        -in $top -anchor n -expand 1 -fill both -side bottom 

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top55 {base} {
    if {$base == ""} {
        set base .top55
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -highlightcolor black 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 1148x299+0+249; update
    wm maxsize $top 2545 994
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "PNS Manager"
    vTcl:DefineAlias "$top" "LPM" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    frame $top.fra83 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame1" vTcl:WidgetProc "LPM" 1
    set site_3_0 $top.fra83
    label $site_3_0.lab96 \
        -disabledforeground #a2a2a2 -text {Configure local PNS:} 
    vTcl:DefineAlias "$site_3_0.lab96" "Label106" vTcl:WidgetProc "LPM" 1
    pack $site_3_0.lab96 \
        -in $site_3_0 -anchor w -expand 0 -fill none -side top 
    button $top.but44 \
        -borderwidth 1 \
        -command {global LPM_fileName
global fileName
# ./pns_utility UTL_CMD = query_eposdb UTL_HOST = pnsmos
puts "FILE: $LPM_fileName"
if { [file exist $LPM_fileName ] } {
    set fowner [file attributes $LPM_fileName -owner]
    set result [run_as $fowner "gedit $LPM_fileName" ]
} elseif { [file exist $fileName ] } {
    set fowner [file attributes $fileName -owner]
    set cmd [concat touch $LPM_fileName \; echo "#File Format:" > $LPM_fileName \; echo "#Version_ID               Path                        #Comment" >> $LPM_fileName \; echo "#2011.2           /apps/PDGM/Paradigm-2011.2/Services         #Example setup" >> $LPM_fileName \; gedit $LPM_fileName ]
    set result [run_as $fowner $cmd ]
    puts "RES: $result"
}
show_lpm
#puts $result} \
        -disabledforeground #a2a2a2 -text Edit... 
    vTcl:DefineAlias "$top.but44" "Button104" vTcl:WidgetProc "LPM" 1
    frame $top.fra88 \
        -borderwidth 2 -height 75 -width 260 
    vTcl:DefineAlias "$top.fra88" "Frame2" vTcl:WidgetProc "LPM" 1
    set site_3_0 $top.fra88
    button $site_3_0.but91 \
        -borderwidth 1 \
        -command {global LPM_name
global LPM_dir
global PNS_host

puts "LPM: $LPM_dir"

if { [string length $LPM_dir] == 0} {
return
}
catch { tk_messageBox -parent .top55 -icon warning -type yesno -title "PNS Manager" -message "Are you sure you want to stop PNS on '$PNS_host'?\n\nROOT password is required..." } ans
if { [ string equal $ans "yes" ] } {
set cmd [ concat $LPM_dir/pns_remove_service ]
set result [get_remote_cmd_result_as root $PNS_host $cmd]
tk_messageBox -parent .top55 -icon info -title "PNS Manager" -message $result
show_lpm
}} \
        -disabledforeground #a2a2a2 -text {Stop selected PNS} 
    vTcl:DefineAlias "$site_3_0.but91" "ButtonPNSstop" vTcl:WidgetProc "LPM" 1
    button $site_3_0.but89 \
        -borderwidth 1 \
        -command {global LPM_name
global LPM_dir
global LPM_runnung_path

global PNS_host
global PNS_ver
global APP_ver



puts "LPM: $LPM_dir"
if { [string length $LPM_dir] == 0} {
return
}
set cmd {}
catch { tk_messageBox -parent .top55 -icon warning -type yesno -title "PNS Manager @ $PNS_host" -message "Are you sure to start/restart PNS on '$PNS_host'?\n\nROOT password is required..." } ans
if { [ string equal $ans "yes" ] } {
    if { [file exist $LPM_running_path/pns_remove_service ] && [file exist $LPM_dir/pns_install_service ]} {
        if { [string equal $LPM_dir $LPM_running_path] } {
            catch { tk_messageBox -parent .top55 -icon warning -type yesno -title "PNS Manager @ $PNS_host" -message "Restart?" } ans
            if { [ string equal $ans "yes" ] } { set cmd [ concat $LPM_dir/pns_remove_service\; sleep 5 \; ]  }
        } else {
            catch { tk_messageBox -parent .top55 -icon warning -type yesno -title "PNS Manager @ $PNS_host" -message "'$PNS_host' is running PNS now.\n\nYou have to stop it to run selected PNS... Stop?" } ans
            if { [ string equal $ans "yes" ] } { set cmd [ concat $LPM_running_path/pns_remove_service \; sleep 5\; ] } { return }
        }
    }
    append cmd append [concat echo -e "\n\n" | $LPM_dir/pns_install_service]
    set result [get_remote_cmd_result_as root $PNS_host $cmd]
    puts "RES: $result"
    tk_messageBox -parent .top55 -icon info -title "PNS Manager @ $PNS_host" -message "PNS operation feedback:\n\n$result"
    show_lpm
}} \
        -disabledforeground #a2a2a2 -text {Start selected PNS} 
    vTcl:DefineAlias "$site_3_0.but89" "ButtonPNSstart" vTcl:WidgetProc "LPM" 1
    button $site_3_0.but44 \
        -borderwidth 1 -command show_lpm -disabledforeground #a2a2a2 \
        -text {Refresh list} 
    vTcl:DefineAlias "$site_3_0.but44" "ButtonRefreshPNSlist" vTcl:WidgetProc "LPM" 1
    button $site_3_0.but43 \
        -borderwidth 1 \
        -command {global Epos_Path
global PNS_dir
global PNS_host
global cmd_env
pgenv 

set pnsm_fn "$PNS_dir/pns_manager"
puts "CALL_PNSM: fn = $pnsm_fn"
if { [file exist $pnsm_fn] } {
    puts [run_as_user [concat $cmd_env\;setenv PNS_HOST $PNS_host\;$pnsm_fn]]
}} \
        -disabledforeground #a2a2a2 -text {Run Epos PNS manager...} 
    vTcl:DefineAlias "$site_3_0.but43" "LPM_run_PM_but" vTcl:WidgetProc "LPM" 1
    pack $site_3_0.but91 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.but89 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    listbox $top.lis84 \
        -background white -borderwidth 1 -disabledforeground #a2a2a2 \
        -exportselection 0 \
        -font [vTcl:font:getFontFromDescr "-family courier -size 12"] \
        -selectmode single -listvariable "$top\::lis84" 
    vTcl:DefineAlias "$top.lis84" "Listbox1" vTcl:WidgetProc "LPM" 1
    label $top.lab87 \
        -disabledforeground #a2a2a2 -text Path: 
    vTcl:DefineAlias "$top.lab87" "Label105" vTcl:WidgetProc "LPM" 1
    label $top.lab48 \
        -borderwidth 1 -disabledforeground #a2a2a2 -relief sunken 
    vTcl:DefineAlias "$top.lab48" "LPM_path_lab" vTcl:WidgetProc "LPM" 1
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra83 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.but44 \
        -in $top -anchor center -expand 0 -fill none -side right 
    pack $top.fra88 \
        -in $top -anchor s -expand 0 -fill x -side bottom 
    pack $top.lis84 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.lab87 \
        -in $top -anchor center -expand 0 -fill x -side left 
    pack $top.lab48 \
        -in $top -anchor center -expand 1 -fill x -side left 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}
#############################################################################
## Binding tag:  _vTclBalloon


if {![info exists vTcl(sourcing)]} {
bind "_vTclBalloon" <<KillBalloon>> {
    namespace eval ::vTcl::balloon {
        after cancel $id
        if {[winfo exists .vTcl.balloon]} {
            destroy .vTcl.balloon
        }
        set set 0
    }
}
bind "_vTclBalloon" <<vTclBalloon>> {
    if {$::vTcl::balloon::first != 1} {break}

    namespace eval ::vTcl::balloon {
        set first 2
        if {![winfo exists .vTcl]} {
            toplevel .vTcl; wm withdraw .vTcl
        }
        if {![winfo exists .vTcl.balloon]} {
            toplevel .vTcl.balloon -bg black
        }
        wm overrideredirect .vTcl.balloon 1
        label .vTcl.balloon.l  -text ${%W} -relief flat  -bg #ffffaa -fg black -padx 2 -pady 0 -anchor w
        pack .vTcl.balloon.l -side left -padx 1 -pady 1
        wm geometry  .vTcl.balloon  +[expr {[winfo rootx %W]+[winfo width %W]/2}]+[expr {[winfo rooty %W]+[winfo height %W]+4}]
        set set 1
    }
}
bind "_vTclBalloon" <Button> {
    namespace eval ::vTcl::balloon {
        set first 0
    }
    vTcl:FireEvent %W <<KillBalloon>>
}
bind "_vTclBalloon" <Enter> {
    namespace eval ::vTcl::balloon {
        ## self defining balloon?
        if {![info exists %W]} {
            vTcl:FireEvent %W <<SetBalloon>>
        }
        set set 0
        set first 1
        set id [after 500 {vTcl:FireEvent %W <<vTclBalloon>>}]
    }
}
bind "_vTclBalloon" <Leave> {
    namespace eval ::vTcl::balloon {
        set first 0
    }
    vTcl:FireEvent %W <<KillBalloon>>
}
bind "_vTclBalloon" <Motion> {
    namespace eval ::vTcl::balloon {
        if {!$set} {
            after cancel $id
            set id [after 500 {vTcl:FireEvent %W <<vTclBalloon>>}]
        }
    }
}
}

Window show .
Window show .top43
Window show .top44
Window show .top55

main $argc $argv
