import XMonad
import XMonad.ManageHook

import XMonad.Util.EZConfig
import XMonad.Util.Ungrab

import XMonad.Layout.ThreeColumns
import XMonad.Layout.Magnifier

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.ManageHelpers

import XMonad.Util.Loggers

main::IO()
main = xmonad 
     . ewmhFullscreen 
     . ewmh 
     . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) toggleStrutsKey
     $ myConfig
  where
    toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
    toggleStrutsKey XConfig{ modMask = m } = (m, xK_b)

myManageHook :: ManageHook
myManageHook = composeAll
  [ isDialog --> doFloat
  ]

myXmobarPP :: PP
myXmobarPP = def
    { ppSep = magenta " • "
    , ppTitleSanitize = xmobarStrip
    , ppCurrent       = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden        = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white "[") (white "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[")(lowWhite "]") . blue . ppWindow

    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""

myLayout = threeColMid ||| tiled ||| Mirror tiled ||| Full
  where
    tiled       = Tall nmain delta ratio
    threeColMid = magnifiercz' 1.6 $ ThreeCol nmain delta ratio
    nmain       = 1      -- Default number of windows in the main pane
    delta       = 3/300  -- Default proportion of screen occupied by main pane
    ratio       = 1/2    -- Percent of screen to increment by when resizing panes

myConfig = def
  { modMask    = mod1Mask     -- Rebind Mod to the Super Key
  , layoutHook = myLayout     -- Use custom layouts
  , manageHook = myManageHook -- Match on certain windows
  }
  `additionalKeysP`
  [ ("M-S-z", spawn "xscreensaver-command -lock")
  , ("M-S-=", unGrab *> spawn "scrot -s"        )
  , ("M-]"  , spawn "firefox"                   )
  , ("M-S-+", spawn "xbacklight -inc 5"         )
  , ("M-S--", spawn "xbacklight -dec 5"         )
  ]

