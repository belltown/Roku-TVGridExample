' TV Listings Grid Screen Example Code, Version 1.0, February 26, 2015
'
' Copyright (c) 2015, belltown. All rights reserved.
'
' Redistribution and use in source and binary forms, with or without
' modification, are permitted provided that the following conditions are met:
'    * Redistributions of source code must retain the above copyright
'        notice, this list of conditions and the following disclaimer.
'    * Redistributions in binary form must reproduce the above copyright
'        notice, this list of conditions and the following disclaimer in the
'        documentation and/or other materials provided with the distribution.
'    * Neither the name of the copyright holder nor the names the contributors may be used to endorse or promote products
'        derived from this software without specific prior written permission.
'
' THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
' ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
' WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
' DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
' DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
' (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
' LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
' ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
' (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
' SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'
'*************************
' TV Listings Grid Example
'*************************
'
' This code is a modified exerpt of code used in the What's On Roku Channnel for the display of TV listings.
' This code is not intended to be used as a "library" or "template" that you can just plug in to your own channel.
' Its purpose is to merely serve as an "example" of how the TV listings display was implemented in the What's On Channel.
' Feel free to use any of the concepts, ideas, or code snippets from this channel in your own implementation.
'

sub Main ()
    displayTVListingsScreen (getSettings ())
end sub

'
' Get application-wide settings
'
function getSettings () as object

    settings = {}
    
    settings.numGridRows        = 6                      ' Supports 4 to 8 channel rows per page
    settings.newDisplayFormat   = true                   ' Use grid display format rather than single-program display. ['*' key toggles between display formats]
    
    settings.colorBG            = "#FF101010"            ' Black [Roku R, G, B color values should not be less than 16]
    settings.colorHeaderBG      = "#FF3A3A3A"            ' Very dark grey
    settings.colorFooter        = "#FF3F3F3F"            ' Medium grey
    settings.colorEven          = "#FF7F7F7F"            ' Light grey
    settings.colorOdd           = "#FF5F5F5F"            ' Darker grey
    settings.colorText          = "#FFEBEBEB"            ' White [Roku R, G, B color values should not be greater than 235]
    
    settings.deviceInfo = getDeviceInfo ()
    settings.font = getFont (settings.deviceInfo.sd, settings.newDisplayFormat, settings.numGridRows)
    settings.dimensions = getDimensions (settings.newDisplayFormat, settings.numGridRows, settings.deviceInfo, settings.font)
    
    return settings
    
end function

'
' Get device-specific settings (fixed for the life of the program)
'
function getDeviceInfo () as object

    deviceInfo = {}

    ' Get Roku's device info
    deviceInfo.di = CreateObject ("roDeviceInfo")
    
    ' Get the TV's display size
    deviceInfo.displaySize = deviceInfo.di.GetDisplaySize ()
    deviceInfo.displayMode = deviceInfo.di.GetDisplayMode ()
    
    ' Get the TV's display mode (true=SD, false=HD)
    if deviceInfo.displayMode = "480i"
        deviceInfo.sd = true
    else
        deviceInfo.sd = false
    endif

    ' Get the current time zone
    tz = deviceInfo.di.GetTimeZone ()
    
    ' Use 7 pm as prime time for Mountain/Central time zones, otherwise 8 pm
    ' Don't adjust time for Canada/Mountain time as they often broadcast on US Pacific time slots
    if tz = "US/Mountain" or tz = "US/Central" or tz = "Canada/Central"
        deviceInfo.primeTime = 19
    else
        deviceInfo.primeTime = 20
    endif
    
    return deviceInfo

end function

'
' Load the font required depending on the number of TV grid rows selected
'
function getFont (sd as boolean, newDisplayFormat as boolean, numGridRows as integer) as object

    font = {}

    minRows = 4
    maxRows = 8

    if numGridRows < minRows
        numGridRows = minRows
    else if numGridRows > maxRows
        numGridRows = maxRows
    endif

    rowIndex = numGridRows - minRows

    ' Font used: http://www.dafont.com/liberation-sans.font
    ' (GNU General Public License v.2)
    fontFile = "pkg:/fonts/Font.ttf"
    fontName = "Liberation Sans"

    ' The font size varies with the number of grid rows
    ' yOffset is a fine-tuning mechanism to center the text vertically within each grid row
    
    if sd
        '                                  4,  5,  6,  7,  8                4,  5,  6,  7,  8
        if newDisplayFormat
            mediumFont =    { fontSize: [ 28, 24, 21, 19, 17 ], yOffset: [ +0, +0, -2, -2, -2 ] }
            smallFont =     { fontSize: [ 22, 20, 18, 16, 15 ], yOffset: [ +0, +6, -1, +0, +0 ] }
        else
            mediumFont =    { fontSize: [ 28, 24, 21, 19, 17 ], yOffset: [ +0, +0, -2, -2, -2 ] }
            smallFont =     { fontSize: [ 22, 19, 17, 16, 14 ], yOffset: [ +0, +2, -1, -3, -2 ] }
        endif
    else	' hd
        if newDisplayFormat
            mediumFont =    { fontSize: [ 42, 37, 33, 29, 24 ], yOffset: [ -1, +0, -2, +0, +0 ] }
            smallFont =     { fontSize: [ 34, 32, 27, 23, 20 ], yOffset: [ -3, +3, +2, +3, +0 ] }
        else
            mediumFont =    { fontSize: [ 42, 37, 33, 29, 24 ], yOffset: [ -1, +0, -2, -2, +0 ] }
            smallFont =     { fontSize: [ 36, 30, 27, 24, 20 ], yOffset: [ +1, +0, -1, -4, -1 ] }
        endif
    endif

    font.fontRegistry = CreateObject ("roFontRegistry")
    font.fontRegistry.Register (fontFile)

    font.mediumFont = {}
    font.mediumFont.yOffset = mediumFont.yOffset [rowIndex]
    font.mediumFont.family = font.fontRegistry.Get (fontName, mediumFont.fontSize [rowIndex], 50, false)
    font.mediumFont.metrics = CreateObject ("roFontMetrics", font.mediumFont.family)

    font.smallFont = {}
    font.smallFont.yOffset = smallFont.yOffset [rowIndex]
    font.smallFont.family = font.fontRegistry.Get (fontName, smallFont.fontSize [rowIndex], 50, false)
    font.smallFont.metrics = CreateObject ("roFontMetrics", font.smallFont.family)
    
    return font
    
end function

'
' Calculate TV grid program display dimensions
'
function getDimensions (newDisplayFormat as boolean, numGridRows as integer, deviceInfo as object, font as object) as object
    
    ' Make use of the 'Action Safe Zone' for display dimensions
    '    HD->1150x646 starting at (64, 35)
    '    SD->648x432, starting at (36, 24)
    if deviceInfo.displayMode = "720p"                                        ' 720 x 1280 display (HD)
        displayH% = 646                                                       ' (720 - 2) * 0.9
        displayW% = 1150                                                      ' (1280 - 2) * 0.9
        displayX% = 64                                                        ' 64 + 1150 + 64 = (1280 - 2)
        displayY% = 35                                                        ' 35 + 646 + 35 = (720 - 4)
    else if deviceInfo.displayMode = "480i"                                   ' 480 x 720 display (SD)
        displayH% = 432                                                       ' 0.9 x 480
        displayW% = 648                                                       ' 0.9 x 720
        displayX% = 36                                                        ' 36 + 432 + 36 = 480
        displayY% = 24                                                        ' 24 + 648 + 24 = 720
    else                                                                      ' Unknown display type
        displayH% = deviceInfo.displaySize.H * 0.9                            ' Set the height to 90% of available screen height
        displayW% = deviceInfo.displaySize.W * 0.9                            ' Scale width to 90% of available screen width
        displayX% = (deviceInfo.displaySize.W - displayW%) / 2                ' Center horizontally
        displayY% = (deviceInfo.displaySize.H - displayH%) / 2                ' Center vertically
    endif

    ' Calculate dimensions of program grid rows
    gridRowH% = (displayH% * 0.93) / numGridRows                              ' Grid row height [reserve 7% of display height for header row]
    gridRowW% = displayW%                                                     ' Program grid occupies entire width of display area
    gridRowX% = displayX%                                                     ' Program grid starts at beginning of display width
    gridRowY% = displayY% + displayH% - (gridRowH% * numGridRows)             ' For first row only, program grid starts at end of header row.
        
    ' Calculate dimensions of header area
    headerRowX% = displayX%                                                   ' Header row starts at beginning of display width
    headerRowY% = displayY%                                                   ' Header row starts at beginning if display height
    headerRowW% = displayW%                                                   ' Header row occupies entire display width
    headerRowH% = displayH% - (gridRowH% * numGridRows)                       ' Header row occupies portion of display height not occupied by program grid rows

    ' Determine the pixel widths for program display
    channelLogoX% = gridRowX% + 10                                            ' Allow some space to the left of the logo
    channelNameW% = font.smallFont.metrics.Size ("WWWWWWW").W * 0.8           ' Only used on single program display
    channelLogoW% = gridRowH%                                                 ' Width occupied by channel logo/channel number
    channelLogoH% = gridRowH% * 2 / 3                                         ' Logo height
    channelLogoImgX% = channelLogoX% + (channelLogoW% - channelLogoH%) / 2    ' Center logo image
    channelNumberH% = gridRowH% - channelLogoH%                               ' Channel number height
    channelNameX% = channelLogoX% + channelLogoW% + 10                        ' Only used for old display mode
    
    if newDisplayFormat
    '
    ' New display format
    '
        programDetailsX% = channelLogoX% + channelLogoW% + 10
        SMALLINTERVAL = 60                                                    ' How much to advance through listings if > key pressed
        LARGEINTERVAL = 180                                                   ' How much to advance through listings if >> key pressed
        SMALLDECREMENT = 60                                                   ' How much to back up through listings if < key pressed
        LARGEDECREMENT = 180                                                  ' How much to back up through listings if << key pressed
        DISPLAYWINDOW = 180                                                   ' When paging forward through listings, to determine if we'll exceed the end of the listings window
    else
    '
    ' Old display format
    '
        programDetailsX% = channelNameX% + channelNameW%                      ' Start of program details area
        SMALLINTERVAL = 30                                                    ' How much to advance through listings if > key pressed
        LARGEINTERVAL = 60                                                    ' How much to advance through listings if >> key pressed
        SMALLDECREMENT = 120                                                  ' How much to back up through listings if < key pressed
        LARGEDECREMENT = 120                                                  ' How much to back up through listings if << key pressed
        DISPLAYWINDOW = 0                                                     ' When paging forward through listings, to determine if we'll exceed the end of the listings window
    endif
    
    programDetailsW% = gridRowW% - programDetailsX%                           ' Width of program details area
    
    dimensions = {
                    displaySizeW: deviceInfo.displaySize.W,
                    displaySizeH: deviceInfo.displaySize.H,
                    displayH: displayH%,
                    displayW: displayW%,
                    displayX: displayX%,
                    displayY: displayY%,
                    headerRowX: headerRowX%,
                    headerRowY: headerRowY%,
                    headerRowW: headerRowW%,
                    headerRowH: headerRowH%,
                    gridRowX: gridRowX%,
                    gridRowY: gridRowY%,
                    gridRowW: gridRowW%,
                    gridRowH: gridRowH%,
                    channelLogoImgX: channelLogoImgX%,
                    channelLogoX: channelLogoX%,
                    channelLogoW: channelLogoW%,
                    channelLogoH: channelLogoH%,
                    channelNameX: channelNameX%,
                    channelNameW: channelNameW%,
                    channelNumberH: channelNumberH%,
                    programDetailsX: programDetailsX%,
                    programDetailsW: programDetailsW%,
                    SMALLINTERVAL: SMALLINTERVAL,
                    LARGEINTERVAL: LARGEINTERVAL,
                    SMALLDECREMENT: SMALLDECREMENT,
                    LARGEDECREMENT: LARGEDECREMENT,
                    DISPLAYWINDOW: DISPLAYWINDOW,
                }

    return dimensions
    
end function

'*******************************
' Display the TV Listings screen
'*******************************
sub displayTVListingsScreen (settings as object)

    primeTime = settings.deviceInfo.primeTime
    numGridRows = settings.numGridRows
    dimensions = settings.dimensions

    port = CreateObject ("roMessagePort")
    
    ' Use an roImageCanvas object that occupies the whole screen for the channel listings grid
    canvas = CreateObject ("roImageCanvas")
    canvas.SetMessagePort (port)
    canvas.AllowUpdates (false)
    
    staticLayer = []

    ' Background
    staticLayer.Push ({Color: settings.colorBG, CompositionMode: "Source"})

    ' Timespan header background
    staticLayer.Push ({
                        TargetRect: {X: 0, Y: dimensions.headerRowY, W: dimensions.displaySizeW, H: dimensions.headerRowH},
                        Color: settings.colorHeaderBG,
                        CompositionMode: "Source"
                    })

    ' Channel background
    nextGridRowY = dimensions.gridRowY
    for row = 0 to numGridRows - 1
        if row mod 2 = 0
            channelBackgroundColor = settings.colorEven
        else
            channelBackgroundColor = settings.colorOdd
        endif
        staticLayer.Push ({
                            TargetRect: {X: 0, Y: nextGridRowY, W: dimensions.displaySizeW, H: dimensions.gridRowH},
                            Color: channelBackgroundColor,
                            CompositionMode: "Source"
                        })
        nextGridRowY = nextGridRowY + dimensions.gridRowH
    end for

    ' Add the static background layer
    canvas.SetLayer (0, staticLayer)
    
    canvas.Show ()

    ' Get the TV Listings
    xml = getTVListings ()
    if xml = Invalid
        displayMessageDialog (["TV Listings Error", "Unable to Retrieve TV Listings"])
        return
    endif
    
    channelCount = xml.Channel.Count ()
    if channelCount = 0
        displayMessageDialog (["TV Listings Error", "No TV Listings found"])
        return
    endif
    
    ' All ...Time fields handle UTC time in seconds
    startTime = getXmlUTCInSecs (xml.TimeInfo.StartTimeUTC)
    endTime = getXmlUTCInSecs (xml.TimeInfo.EndTimeUTC)
    currentTime = startTime
    currentTimeStr = timeToStr (currentTime)
    
    ' Channel details layer
    canvas.SetLayer (1, getChannelLayer (settings, xml, 0, currentTime, currentTimeStr, startTime))
    canvas.AllowUpdates (true)
    
    channelIndex = 0
    
    while true
        msg = Wait (0, port)
        if type (msg) = "roImageCanvasEvent"
            if msg.IsScreenClosed ()
                exit while
            else if msg.IsRemoteKeyPressed ()
                key = msg.GetIndex ()
                
                ' <DOWN> Next Channel Group
                if key = 3
                    if channelCount > numGridRows        ' No change if only one page of channels
                        channelIndex = channelIndex + numGridRows
                        if channelIndex >= channelCount
                            channelIndex = 0
                            if channelIndex >= channelCount then channelIndex = channelCount - 1
                        endif
                        canvas.SetLayer (1, getChannelLayer (settings, xml, channelIndex, currentTime, currentTimeStr, startTime))
                    endif
                    
                ' <UP> Previous Channel Group
                else if key = 2
                    if channelCount > numGridRows        ' No change if only one page of channels
                        if channelIndex > 0 and channelIndex < numGridRows
                            channelIndex = 0
                        else
                            channelIndex = channelIndex - numGridRows
                            if channelIndex < 0
                                channelIndex = channelCount - numGridRows
                                if channelIndex < 0 then channelIndex = 0
                            endif
                        endif
                        canvas.SetLayer (1, getChannelLayer (settings, xml, channelIndex, currentTime, currentTimeStr, startTime))
                    endif
                    
                ' <RIGHT> Next Time Period (+30 mins)
                else if key = 5
                    currentTime = currentTime + (dimensions.SMALLINTERVAL * 60)
                    currentTimeStr = timeToStr (currentTime)
                    if currentTime + dimensions.DISPLAYWINDOW * 60 >= endTime
                        ' We've reached the end of the time period for the current grid
                        tvListings = getTVListings (currentTime.ToStr ())
                        if tvListings = Invalid
                            return
                        endif
                        channelCount = xml.Channel.Count ()
                        startTime = getXmlUTCInSecs (xml.TimeInfo.StartTimeUTC, currentTime)
                        endTime = getXmlUTCInSecs (xml.TimeInfo.EndTimeUTC, currentTime)
                        ' Allow for case when TV listings returned for a different time from what was requested
                        if (startTime > currentTime and endTime > currentTime) or (startTime < currentTime and endTime < currentTime)
                            currentTime = startTime
                            currentTimeStr = timeToStr (currentTime)
                        endif
                        if channelCount = 0
                            displayMessageDialog (["TV Listings Error", "No TV Listings found"])
                            canvas.Close ()
                            return
                        endif
                    endif
                    canvas.SetLayer (1, getChannelLayer (settings, xml, channelIndex, currentTime, currentTimeStr, startTime))
                    
                ' <LEFT> Previous Time Period (-30 mins)
                else if key = 4
                    currentTime = currentTime - (dimensions.SMALLINTERVAL * 60)
                    currentTimeStr = timeToStr (currentTime)
                    if currentTime < startTime
                        tvListings = getTVListings ((startTime - (dimensions.SMALLDECREMENT * 60)).ToStr ())
                        if tvListings = Invalid
                            return
                        endif
                        channelCount = xml.Channel.Count ()
                        startTime = getXmlUTCInSecs (xml.TimeInfo.StartTimeUTC, currentTime)
                        endTime = getXmlUTCInSecs (xml.TimeInfo.EndTimeUTC, currentTime)
                        if (startTime > currentTime and endTime > currentTime) or (startTime < currentTime and endTime < currentTime)
                            currentTime = startTime
                            currentTimeStr = timeToStr (currentTime)
                        endif
                        if channelCount = 0
                            displayMessageDialog (["TV Listings Error", "No TV Listings found"])
                            canvas.Close ()
                            return
                        endif
                    endif
                    canvas.SetLayer (1, getChannelLayer (settings, xml, channelIndex, currentTime, currentTimeStr, startTime))
                    
                ' <REW> Previous Time Period (-60 mins)
                else if key = 8
                    currentTime = currentTime - (dimensions.LARGEINTERVAL * 60)
                    currentTimeStr = timeToStr (currentTime)
                    if currentTime < startTime
                        tvListings = getTVListings ((startTime - (dimensions.LARGEDECREMENT * 60)).ToStr ())
                        if tvListings = Invalid
                            return
                        endif
                        channelCount = xml.Channel.Count ()
                        startTime = getXmlUTCInSecs (xml.TimeInfo.StartTimeUTC, currentTime)
                        endTime = getXmlUTCInSecs (xml.TimeInfo.EndTimeUTC, currentTime)
                        if (startTime > currentTime and endTime > currentTime) or (startTime < currentTime and endTime < currentTime)
                            currentTime = startTime
                            currentTimeStr = timeToStr (currentTime)
                        endif
                        if channelCount = 0
                            displayMessageDialog (["TV Listings Error", "No TV Listings found"])
                            canvas.Close ()
                            return
                        endif
                    endif
                    canvas.SetLayer (1, getChannelLayer (settings, xml, channelIndex, currentTime, currentTimeStr, startTime))
                    
                ' <FF> Next Time Period (+60 mins)
                else if key = 9
                    currentTime = currentTime + (dimensions.LARGEINTERVAL * 60)
                    currentTimeStr = timeToStr (currentTime)
                    if currentTime + dimensions.DISPLAYWINDOW * 60 >= endTime
                        ' We've reached the end of the time period for the current grid
                        tvListings = getTVListings (currentTime.ToStr ())
                        if tvListings = Invalid
                            return
                        endif
                        channelCount = xml.Channel.Count ()
                        startTime = getXmlUTCInSecs (xml.TimeInfo.StartTimeUTC, currentTime)
                        endTime = getXmlUTCInSecs (xml.TimeInfo.EndTimeUTC, currentTime)
                        if (startTime > currentTime and endTime > currentTime) or (startTime < currentTime and endTime < currentTime)
                            currentTime = startTime
                            currentTimeStr = timeToStr (currentTime)
                        endif
                        if channelCount = 0
                            displayMessageDialog (["TV Listings Error", "No TV Listings found"])
                            canvas.Close ()
                            return
                        endif
                    endif
                    canvas.SetLayer (1, getChannelLayer (settings, xml, channelIndex, currentTime, currentTimeStr, startTime))
                    
                ' <Play/Pause> Go to Prime Time
                else if key = 13
                    ' Prime Time is considered to be the next occurence of 8pm (2000 hrs local time) after the current time
                    dt = CreateObject ("roDateTime")
                    dt.FromSeconds (currentTime)
                    dt.ToLocalTime ()
                    hh = dt.GetHours ()
                    mm = dt.GetMinutes ()
                    ss = dt.GetSeconds ()
                    if hh < primeTime
                        secsFromMidnight = ((hh * 60) + mm) * 60 + ss
                        nextPrimeTime = currentTime - secsFromMidnight + (primeTime * 60 * 60)
                    else
                        secsFromPrimeTime = (((hh - primeTime) * 60) + mm) * 60 + ss
                        nextPrimeTime = currentTime - secsFromPrimeTime + (24 * 60 * 60)
                    endif
                    currentTime = nextPrimeTime
                    currentTimeStr = timeToStr (currentTime)
                    tvListings = getTVListings (currentTime.ToStr ())
                    if tvListings = Invalid
                        return
                    endif
                    channelCount = xml.Channel.Count ()
                    startTime = getXmlUTCInSecs (xml.TimeInfo.StartTimeUTC, currentTime)
                    endTime = getXmlUTCInSecs (xml.TimeInfo.EndTimeUTC, currentTime)
                    if (startTime > currentTime and endTime > currentTime) or (startTime < currentTime and endTime < currentTime)
                        currentTime = startTime
                        currentTimeStr = timeToStr (currentTime)
                    endif
                    if channelCount = 0
                        displayMessageDialog (["TV Listings Error", "No TV Listings found"])
                        canvas.Close ()
                        return
                    endif
                    canvas.SetLayer (1, getChannelLayer (settings, xml, channelIndex, currentTime, currentTimeStr, startTime))
                
                ' <OK> or <BACK> Back to Main Screen    
                else if key = 6    or key = 0
                    canvas.Close ()
                    
                ' * - Change display format
                else if key = 10
                    toggleDisplayFormat (settings)
                    dimensions = settings.dimensions
                    ' If switching to the new display format, set the current time to the start of the listings window
                    if settings.newDisplayFormat
                        startTime = getXmlUTCInSecs (xml.TimeInfo.StartTimeUTC)
                        endTime = getXmlUTCInSecs (xml.TimeInfo.EndTimeUTC)
                        currentTime = startTime
                        currentTimeStr = timeToStr (currentTime)
                    endif
                    canvas.SetLayer (1, getChannelLayer (settings, xml, channelIndex, currentTime, currentTimeStr, startTime))
                endif
                
            endif
        endif
    end while

end sub

'****************
' Get TV listings
'****************
function getTVListings (timeInSecs = "" as string) as object

    loadingDialog = displayLoadingDialog ()
    
    xmlData = ReadAsciiFile ("pkg:/xml/example.xml")
    xml = CreateObject ("roXMLElement")
    if not xml.Parse (xmlData)
        xml = Invalid
    endif
    
    closeLoadingDialog (loadingDialog)
    
    return xml

end function

function timeToStr (displayTime as integer) as string

    ' Get the present time
    dtNow = CreateObject ("roDateTime")
    dtNow.Mark ()
    dtNow.ToLocalTime ()

    ' Calculate the start time for the time span of the displayed time
    dt = CreateObject ("roDateTime")
    dt.FromSeconds (displayTime)
    dt.ToLocalTime ()
    h = dt.GetHours ()
    mm = dt.GetMinutes () : mmStr = Right ("0" + mm.ToStr (), 2)
    if h = 0 and mm = 0
        timeStr = "Midnight"
    else if h = 12 and mm = 0
        timeStr = "Noon"
    else
        if h >= 12
            ap = "pm"
            if h > 12 then h = h - 12
        else
            ap = "am"
        endif
        timeStr = h.ToStr () + ":" + mmStr + " " + ap
    endif

    ' If the date of the displayed time is not the current date then display the date as well as the displayed time
    if dtNow.AsDateString ("short-date") <> dt.AsDateString ("short-date")
        monthList = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        timeStr = Left (dt.GetWeekday (), 3) + " " + monthList [dt.GetMonth ()] + " " + dt.GetDayOfMonth ().ToStr () +  " - " + timeStr
    endif

    return timeStr

end function

function getChannelLayer (settings as object, xml as object, channelIndex as integer, currentTime as integer, currentTimeStr as string, startTime as integer) as object

    dimensions = settings.dimensions
    font = settings.font
    
    ' Duration is the total time span for program results returned in this XML response (should be 3 hours)
    duration = getXmlUTCInSecs (xml.TimeInfo.EndTimeUTC) - getXmlUTCInSecs (xml.TimeInfo.StartTimeUTC)

    layer = []

    ' Header containing timespan
    if not settings.newDisplayFormat
    '
    ' Old display format
    '
        layer.Push ({
                        TargetRect: {X: dimensions.headerRowX, Y: dimensions.headerRowY, W: dimensions.headerRowW, H: dimensions.headerRowH},
                        Text: currentTimeStr,
                        TextAttrs: {Color: settings.colorText, Font: font.mediumFont.family, HAlign: "Center", VAlign: "Middle"}
                    })
    else
    '
    ' New display format
    '
        ' Display the day and the start time
        startDay = timeToDay (startTime)
        layer.Push ({
                        TargetRect: {X: dimensions.headerRowX, Y: dimensions.headerRowY, W: dimensions.programDetailsX - dimensions.headerRowX, H: dimensions.headerRowH},
                        Text: startDay,
                        TextAttrs: {Color: settings.colorText, Font: font.mediumFont.family, HAlign: "Left", VAlign: "Middle"}
                    })
        startHMMA = timeToHMMA2 (startTime)
        timeX% = dimensions.programDetailsX
        timeW% = dimensions.programDetailsW * 60 * 60 / duration
        layer.Push ({
                        TargetRect: {X: timeX%, Y: dimensions.headerRowY, W: timeW%, H: dimensions.headerRowH},
                        Text: startHMMA,
                        TextAttrs: {Color: settings.colorText, Font: font.mediumFont.family, HAlign: "Left", VAlign: "Middle"}
                    })
        
        ' Display the start time + 60 mins if there is at least 2 hours' worth of listings
        if duration >= 120 * 60
            startHMMA = timeToHMMA2 (startTime + 60 * 60)
            timeStr = startHMMA
            timeX% = dimensions.programDetailsX + timeW%
            timeW% = dimensions.programDetailsW * 120 * 60 / duration
            layer.Push ({
                            TargetRect: {X: timeX%, Y: dimensions.headerRowY, W: timeW%, H: dimensions.headerRowH},
                            Text: timeStr,
                            TextAttrs: {Color: settings.colorText, Font: font.mediumFont.family, HAlign: "Left", VAlign: "Middle"}
                        })
        endif
        
        ' Display the start time + 120  if there is at least 3 hours' worth of listings
        if duration >= 180 * 60
            startHMMA = timeToHMMA2 (startTime + 120 * 60)
            timeStr = startHMMA
            timeX% = dimensions.programDetailsX + timeW%
            timeW% = dimensions.programDetailsW * 180 * 60 / duration
            layer.Push ({
                            TargetRect: {X: timeX%, Y: dimensions.headerRowY, W: timeW%, H: dimensions.headerRowH},
                            Text: timeStr,
                            TextAttrs: {Color: settings.colorText, Font: font.mediumFont.family, HAlign: "Left", VAlign: "Middle"}
                        })
        endif
        
        ' Don't attempt to display more that 3 hours' worth of listings
        if duration > 180 * 60
            duration = 180 * 60
        endif
        
    endif
    
    nextGridRowY = dimensions.gridRowY
    
    '
    ' Display each row of channel information
    '
    for row = 0 to settings.numGridRows - 1
        channel = xml.Channel [channelIndex]
        logoUrl = ""
        
        ' Channel background
        if row mod 2 = 0
            channelBackgroundColor = settings.colorEven
        else
            channelBackgroundColor = settings.colorOdd
        endif
        layer.Push ({
                        TargetRect: {X: 0, Y: nextGridRowY, W: dimensions.displayW, H: dimensions.gridRowH},
                        Color: channelBackgroundColor,
                        CompositionMode: "Source"
                    })
        
        if not settings.newDisplayFormat
        '
        ' Single Program display format
        '
            ' Channel Logo
            logoUrl = getXmlString (channel.ChannelData.ChannelLogo)
            if logoUrl <> ""
                layer.Push ({
                                TargetRect: {X: dimensions.channelLogoImgX, Y: nextGridRowY, W: dimensions.channelLogoH, H: dimensions.channelLogoH},
                                Url: logoUrl
                            })
            endif

            ' Channel Number
            channelNumber = getXmlString (channel.ChannelData.ChannelNumber)
            channelNumberBox = textBoxCreate (dimensions.channelLogoX, nextGridRowY + dimensions.channelLogoH, dimensions.channelLogoW, dimensions.channelNumberH, settings.colorText, "Center")
            channelNumberBox.addLine (channelNumber, font.mediumFont, dimensions.channelLogoW)
            channelNumberBox.addToLayer (layer)

            ' Channel Name
            channelName = getXmlString (channel.ChannelData.ChannelName)
            channelNameBox = textBoxCreate (dimensions.channelNameX, nextGridRowY + 3, dimensions.channelNameW, dimensions.gridRowH, settings.colorText)
            channelNameBox.addLine (channelName, font.smallFont)
            channelNameBox.addToLayer (layer)

            ' Program Details
            currentProgram = Invalid
            program = Invalid
            ' Loop for each program for this channel
            for programIndex = 0 to channel.ProgramList.Program.Count () - 1
                program = channel.ProgramList.Program [programIndex]
                startTimeSecs = getXmlInteger (program.StartSecs) + startTime
                endTimeSecs = getXmlInteger (program.EndSecs) + startTime
                ' Display the first program having an end time greater than the current display time (or the last program)
                if endTimeSecs > currentTime and currentProgram = Invalid
                    currentProgram = program
                endif
                ' Give preferential display to programs that are less than 30 minutes long and don't start on or span a half-hour boundary
                if startTimeSecs > currentTime and endTimeSecs <= (currentTime + 30 * 60)
                    currentProgram = program
                endif
            end for
            
            ' If a program was found then use it, otherwise use the last program encountered
            if currentProgram <> Invalid
                program = currentProgram
            endif

            if program <> Invalid
                programName = getXmlString (program.ProgramName)
                programYear = getXmlString (program.ProgramYear)
                programDesc = getXmlString (program.ProgramDescription)
                startTimeSecs =  getXmlInteger (program.StartSecs) + startTime        ' program.StartSecs is start time (secs) relative to start of XML
                endTimeSecs =  getXmlInteger (program.EndSecs) + startTime        ' program.EndSecs is end time (secs) relative to start of XML
                if startTimeSecs <> 0 then startTimeStr = timeToHMMA (startTimeSecs) else startTimeStr = ""
                if endTimeSecs <> 0 then endTimeStr = timeToHMMA (endTimeSecs) else endTimeStr = ""
                runTime = getXmlString (program.RuntimeMins)                            ' program.RuntimeMins is total duration (mins) of the program
                attributesConcat = getXmlString (program.ProgramAttributes)
                displayTime = startTimeStr + "-" + endTimeStr + "  (" + runTime + " mins)" + "    " + attributesConcat            
                programDetailsBox = textBoxCreate (dimensions.programDetailsX, nextGridRowY + 0, dimensions.programDetailsW, dimensions.gridRowH - 2, settings.colorText)
                programDetailsBox.addLine (programName + "  " + programYear,  font.mediumFont)
                programDetailsBox.addLine (programDesc, font.smallFont)
                programDetailsBox.addLine (displayTime, font.smallFont)
                programDetailsBox.addToLayer (layer)
            endif
            
        else
        '
        ' Grid display format
        '    
            ' Channel Logo
            logoUrl = getXmlString (channel.ChannelData.ChannelLogo)
            if logoUrl <> ""
                layer.Push ({
                                TargetRect: {X: dimensions.channelLogoImgX, Y: nextGridRowY, W: dimensions.channelLogoH, H: dimensions.channelLogoH},
                                Url: logoUrl
                            })
            endif

            ' Channel Number
            channelNumber = getXmlString (channel.ChannelData.ChannelNumber)
            channelNumberBox = textBoxCreate (dimensions.channelLogoX, nextGridRowY + dimensions.channelLogoH, dimensions.channelLogoW, dimensions.channelNumberH, settings.colorText, "Center")
            channelNumberBox.addLine (channelNumber, font.mediumFont, dimensions.channelLogoW)
            channelNumberBox.addToLayer (layer)

            '
            ' Loop for each program in this channel
            '
            for programIndex = 0 to channel.ProgramList.Program.Count () - 1
            
                ' Get the next program
                program = channel.ProgramList.Program [programIndex]
                
                ' startRel and endRel are the number of seconds relative to the start of the current listings window
                startRel = getXmlInteger (program.StartSecs)
                endRel = getXmlInteger (program.EndSecs)
                
                ' Don't attempt to display programs that start more than 15 minutes before the end of the 3-hour maximum display duration
                if startRel <= duration - (15 * 60)
                
                    ' Don't attempt to display any portion of the program that exceeds the end of the 3-hour maximum display duration
                    if endRel > duration then endRel = duration
                    
                    ' Determine the proportion of the display width to be occupied by this program
                    programDuration = endRel - startRel
                    
                    ' Get width in pixels of current program display box
                    programWidth% = dimensions.programDetailsW * programDuration / duration
                    
                    ' Get X-coordinate of start of current program display box
                    programStart% = dimensions.programDetailsX + dimensions.programDetailsW * startRel / duration
                    
                    programName = getXmlString (program.ProgramName)
                    programDetailsBox = textBoxCreate (programStart%, nextGridRowY + 0, programWidth%, dimensions.gridRowH - 2, settings.colorText)
                    programDetailsBox.addText (programName,  font.smallFont, programWidth%, dimensions.gridRowH, channelBackgroundColor)
                    programDetailsBox.addToLayer (layer)
                endif
            end for
            '
            ' If there are no programs listed for this channel, write in a blank program
            '
            if channel.ProgramList.Program.Count () = 0
                programName = "No Listings"
                programWidth% = dimensions.programDetailsW
                programStart% = dimensions.programDetailsX
                programDetailsBox = textBoxCreate (programStart%, nextGridRowY + 0, programWidth%, dimensions.gridRowH - 2, settings.colorText)
                programDetailsBox.addText (programName,  font.smallFont, programWidth%, dimensions.gridRowH, channelBackgroundColor)
                programDetailsBox.addToLayer (layer)
            endif
        endif

        nextGridRowY = nextGridRowY + dimensions.gridRowH
        
        ' Go to the next channel
        channelIndex = channelIndex + 1
        
        ' No wraparound. Once the last channel is reached, don't display any more channels past it on this screen
        if channelIndex >= xml.Channel.Count ()
            exit for
        endif
        
    end for
    
    '
    ' Write a blank layer under the program grid to cover up any text that overflowed its box
    '
    layer.Push ({TargetRect: {X: 0, Y: nextGridRowY, W: dimensions.displaySizeW, H: dimensions.displaySizeH - nextGridRowY}, Color: settings.colorFooter, CompositionMode: "Source"})
    
    return layer
    
end function

function textBoxCreate (xParam as integer, yParam as integer, wParam as integer, hParam as integer, colorParam as string, hAlignParam = "Left" as string) as object

    textBox = {}
    
    textBox.x = xParam
    textBox.y = yParam
    textBox.w = wParam
    textBox.h = hParam
    textBox.textColor = colorParam
    textBox.hAlign = hAlignParam

    textBox.outputBox = []
    textBox.numLines = 0
    textBox.nextY = textBox.y
    
    ' Add a single line of text
    textBox.addLine = function (textParam as string, fontParam as object, maxWidth = -1 as integer)
        if textParam <> ""
            size = fontParam.metrics.Size (textParam)
            if maxWidth = -1
                width = size.W
            else
                width = maxWidth
            endif
            yOffset = fontParam.yOffset

            m.outputBox.Push ({
                                TargetRect: {X: m.x, Y: m.nextY + yOffset, W: width, H: size.H},
                                Text: textParam,
                                TextAttrs: {Color: m.textColor, Font: fontParam.family, HAlign: m.hAlign, VAlign: "Top"}
                                })
            m.nextY = m.nextY + size.H
            m.numLines = m.numLines + 1
        endif

    end function
    
    ' Fill the box with text, drawing the background to overwrite any text that might overlap from a previous operation
    textBox.addText = function (textParam as string, fontParam as object, boxWidth as integer, boxHeight as integer, channelBackgroundColor as string)
        if textParam <> ""
            size = fontParam.metrics.Size (textParam)
            yOffset = fontParam.yOffset
            ' Background rectangle. Allow it to extend into the rectangle on the LHS so as to allow padding between programs
            m.outputBox.Push ({TargetRect: {X: m.x - 1, Y: m.nextY + yOffset, W: boxWidth + 1, H: boxHeight}, Color: channelBackgroundColor, CompositionMode: "Source"})
            ' Vertical line between programs
            m.outputBox.Push ({TargetRect: {X: m.x, Y: m.nextY + yOffset, W: 1, H: boxHeight}, Color: m.textColor, CompositionMode: "Source"})
            ' Program details
            m.outputBox.Push ({
                                TargetRect: {X: m.x + 2, Y: m.nextY + yOffset, W: boxWidth - 3, H: size.H},
                                Text: textParam,
                                TextAttrs: {Color: m.textColor, Font: fontParam.family, HAlign: m.hAlign, VAlign: "Top"}
                            })
            m.nextY = m.nextY + size.H
            m.numLines = m.numLines + 1
        endif

    end function
    
    textBox.addToLayer = function (layer as object)

        for each item in m.outputBox
            layer.Push (item)
        end for
        
    end function
    
    return textBox

end function

'
' Switch from old display format to new display format or vice-versa
'
function toggleDisplayFormat (settings as object)

    if settings.newDisplayFormat = true
        settings.newDisplayFormat = false
    else
        settings.newDisplayFormat = true
    endif

    settings.font = getFont (settings.deviceInfo.sd, settings.newDisplayFormat, settings.numGridRows)
    settings.dimensions = getDimensions (settings.newDisplayFormat, settings.numGridRows, settings.deviceInfo, settings.font)
    
end function

function timeToHMMA (timeSecs as integer) as string

    dt = CreateObject ("roDateTime")
    dt.FromSeconds (timeSecs)
    dt.ToLocalTime ()

    h = dt.GetHours ()
    mm = dt.GetMinutes () : mmStr = Right ("0" + mm.ToStr (), 2)
    if h < 12
        ap = "am"
    else
        if h > 12 then h = h - 12
        ap = "pm"
    endif
    
    return h.ToStr () + ":" + mmStr + " " + ap

end function

function timeToHMMA2 (timeSecs as integer) as string

    dt = CreateObject ("roDateTime")
    dt.FromSeconds (timeSecs)
    dt.ToLocalTime ()

    h = dt.GetHours ()
    mm = dt.GetMinutes () : mmStr = Right ("0" + mm.ToStr (), 2)

    if h = 0 and mm = 0
        timeStr = "Midnight"
    else if h = 12 and mm = 0
        timeStr = "Noon"
    else
        if h >= 12
            ap = "pm"
            if h > 12 then h = h - 12
        else
            ap = "am"
        endif
        timeStr = h.ToStr () + ":" + mmStr + " " + ap
    endif
    
    return timeStr

end function

function timeToDay (timeSecs as integer) as string

    dt = CreateObject ("roDateTime")
    dt.FromSeconds (timeSecs)
    dt.ToLocalTime ()

    return Left (dt.GetWeekday (), 3)

end function

'
' Get a string from an XML field
'
function getXmlString (field as object, defaultField = "" as string) as string

    for each item in field
        return field.GetText ()
    end for

    return defaultField

end function

'
' Get an integer from an XML field
'
function getXmlInteger (field as object, defaultField = 0 as integer) as integer

    for each item in field
        return field.GetText ().ToInt ()
    end for

    return defaultField

end function

'
' Get an ISO8601 UTC time from an XML field and convert to time in seconds
'
function getXmlUTCInSecs (field as object, defaultField = 0 as integer) as integer

    utcString = ""
    for each item in field
        utcString = field.GetText ()
        exit for
    end for
    
    dt = CreateObject ("roDateTime")
    dt.FromISO8601String (utcString)
    secs = dt.AsSeconds ()
    
    if secs > 1300000000 and secs < 1500000000
        timeSecs = secs
    else
        timeSecs = defaultField
    endif
    
    return timeSecs

end function

'*************************
' Display a message dialog
'*************************
sub displayMessageDialog (messageList as object)

    port = CreateObject ("roMessagePort")

    messageDialog = CreateObject ("roMessageDialog")
    messageDialog.SetMessagePort (port)
    messageDialog.EnableOverlay (true)    ' Do not dim background screen
    messageDialog.SetTitle (messageList [0])
    for i = 1 to messageList.Count () - 1
        messageDialog.SetText (messageList [i])
    end for
    messageDialog.AddButton (1, "OK")
    messageDialog.Show ()

    while true
        msg = Wait (0, port)
        if type (msg) = "roMessageDialogEvent"
            if msg.IsScreenClosed ()
                exit while
            else if msg.IsButtonPressed ()
                if msg.GetIndex () = 1
                    messageDialog.Close ()
                endif
            endif
        endif
    end while

end sub

'*******************************
' Display a one-line busy dialog
'*******************************
function displayLoadingDialog () as object

    port = CreateObject ("roMessagePort")

    oneLineDialog = CreateObject ("roOneLineDialog")
    oneLineDialog.SetMessagePort (port)
    oneLineDialog.ShowBusyAnimation ()
    oneLineDialog.SetTitle ("Loading ...")
    oneLineDialog.Show ()
    
    return oneLineDialog
    
end function

'*****************************
' Close a one-line busy dialog
'*****************************
function closeLoadingDialog (dialog as object) as object

    dialog.Close ()
    while true
        msg = Wait (0, dialog.GetMessagePort ())
        if msg.IsScreenClosed ()
            exit while
        endif
    end while

end function