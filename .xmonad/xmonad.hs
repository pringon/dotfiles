-- My Xmonad configuration 
--
-- Template was copied from the archive at:
-- https://wiki.haskell.org/Xmonad/Config_archive

-- IMPORTS

import XMonad
import XMonad.Actions.Submap
import XMonad.Util.SpawnOnce

import qualified XMonad.StackSet as W

import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import qualified XMonad.Layout.Fullscreen as Fullscreen

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks

import qualified Data.Map        as M

import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String as UTF8

myTerminal :: String
myTerminal      = "termite"

myWorkspaces :: [String]
myWorkspaces    = ["1: 💻","2: 📖","3","4","5","6","7","8: 🧑🧑","9: 🎵"]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- BORDER
myNormalBorderColor :: String
myNormalBorderColor  = "#dddddd"

myFocusedBorderColor :: String
myFocusedBorderColor = "#d92a07"

myBorderWidth :: Dimension
myBorderWidth   = 2

-----------------
--- BINDINGS
-----------------

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm              ,  xK_d     ), spawn "rofi -show combi -config $HOME/.config/i3/rofi.conf")

    -- close focused window
    , ((modm .|. shiftMask, xK_q     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm              , xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    -- , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile && xmonad --restart\
                                              \&& notify-send -t 2000 \"Xmonad updated!\"")

    -- Power mode
    , ((modm             , xK_p     ), notifyPowerModeOptions)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myModMask :: KeyMask
myModMask       = mod4Mask

notifyPowerModeOptions :: X ()
notifyPowerModeOptions = do
  spawn $ "notify-send --expire-time=1000 \"Power Mode\" \"" ++ powerModeNotificationBody ++ "\""
  submap powerModeOptions
  where
    powerModeNotificationBody = "The following options are available\n\
                                \Lock: Mod + L\n\
                                \Reboot: Mod + R\n\
                                \Exit: Mod + E\n\
                                \Suspend: Mod + S\n\
                                \Shutdown: Mod + Shift + S\n\
                                \Cancel: Esc"
    powerModeOptions = M.fromList $ [((0         , xK_l),     spawn "$HOME/.config/i3/scripts/lock.sh")
                                    ,((0         , xK_r),     spawn "reboot")
                                    ,((0         , xK_e),     spawn "kill -9 -1")
                                    ,((0         , xK_s),     spawn "$HOME/.config/i3/scripts/suspend.sh")
                                    ,((shiftMask , xK_space), spawn "shutdown")
                                    ]

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]


---------------
--- LAYOUTS
---------------

myLayout = tiled ||| Mirror tiled ||| fullscreen
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled      = Tall nmaster delta ratio
    fullscreen = noBorders Full

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100


------------
-- INIT
--------------

myStartupHook = do
  spawnOnce "setxkbmap us -option caps:swapescape"
  spawnOnce "xset r rate 200"
  spawnOnce "polybar -c ~/.config/polybar/config xmonad-status -r &"
  spawnOnce "picom &"
  spawnOnce "trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --width 10 --transparent true --tint 0x191970 --height 12 &"
  spawnOnce "nitrogen --restore &"
  spawnOnce "emacs --daemon"


-----------------------------------
-- STATUS BAR STUFF (DBUS related)
-----------------------------------

myLogHook :: D.Client -> PP
myLogHook dbus = def { ppOutput = dbusOutput dbus }

-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
    let signal = (D.signal objectPath interfaceName memberName) {
            D.signalBody = [D.toVariant $ UTF8.decodeString str]
        }
    D.emit dbus signal
    where
        objectPath = D.objectPath_ "/org/xmonad/Log"
        interfaceName = D.interfaceName_ "org.xmonad.Log"
        memberName = D.memberName_ "Update"


main = do
    dbus <- D.connectSession
    -- Request access to the DBus name
    _ <- D.requestName dbus (D.busName_ "org.xmonad.Log")
        [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
    xmonad . ewmh . Fullscreen.fullscreenSupport . docks $ def
        { terminal           = myTerminal
        , focusFollowsMouse  = myFocusFollowsMouse
        , borderWidth        = myBorderWidth
        , modMask            = myModMask
        , workspaces         = myWorkspaces
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        -- key bindings
        , keys               = myKeys
        , mouseBindings      = myMouseBindings
        -- hooks, layouts
        , layoutHook         = windowGaps . avoidStruts $ myLayout
        , logHook            = dynamicLogWithPP (myLogHook dbus)
        , startupHook        = myStartupHook
        }
    where
        windowGaps = spacingRaw True (Border 0 0 0 0) False (Border 0 5 5 0) True
