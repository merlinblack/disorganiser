-- Global definition file for Lua language server.

-- C++ defined Classes

--- Application class
--- @class Application
--- @field ticks number Number of ticks since application started.
--- @field shouldRestart boolean Should the application restart.
--- @field shouldStop boolean Should the application stop and exit.
--- @field showCursor boolean Determins if the mouse cursor is visible.
--- @field renderList RenderList Main application render list
--- @field overlay RenderList Secondary application render list, shown on top
--- @field textInputMode boolean Is SDL's textInputMode enabled or not.
--- @field emptyTexture Texture A blank tiny texture for use as a placeholder.
--- @field width number Application window width in pixels.
--- @field height number Application window height in pixels.
Application = {}

--- @class Atlas
Atlas = {}

--- @class Color
--- @field r number Red 0 - 255
--- @field g number Green 0 - 255
--- @field b number Blue 0 - 255
Color = {}

--- @class EditString 
EditString = {}

--- @class Font 
Font = {}

--- @class LineList : Renderable
LineList = {}

--- @class ProcessReader 
ProcessReader = {}

--- @class Rectangle : Renderable
Rectangle = {}

--- Base class for all classes that have a 'render' function can be put into a render list.
--- @class Renderable 
Renderable = {}

--- @class Renderer 
Renderer = {}

--- @class RenderList : Renderable
RenderList = {}
--- Add a renderable element to a render list
--- @param element Renderable
function RenderList:add(element) end
--- Remove a renderable element from a render list
--- @param element Renderable
function RenderList:remove(element) end
--- Set wheather a render list should render on next 'turn'
--- @param shouldRender? boolean Defaults to true
function RenderList:shouldRender(shouldRender) end
--- Remove all elements from a render list
function RenderList:clear() end

--- @class Texture 
Texture = {}

-- C++ defined instances and functions

--- Application instance
--- @class Application
app = {}

--- Add a task to the task list.
--- Task will be removed when the function ends.
--- @return string name Name of the task
--- @param taskFunc function Lua function to run as a task
--- @param name? string Optional name for the task
addTask = function(taskFunc, name) return '' end

--- Get a list of all current tasks
--- @return table list Table of strings
getTasks = function() return {} end

--- Get the name of the currently running task
--- @return string name
getCurrentTaskName = function() return '' end

--- Cause a task that is waiting to return from wait() on next 'turn'
--- @param name string Name of the task to wake.
wakeTask = function(name) end

--- Cause a task that is waiting to be asked to terminate on next 'turn'
--- @param name string Name of the task to kill.
killTask = function(name) end

-- Lua defined classes
--- @class Class 
--- @field __type string Name of the class.
Class = {}

--- @class Widget : Class
--- @field updateAction function If set, action to take on update.
Widget = {}

--- @class Button : Widget 
Button = {}

--- @class Screen : Widget
--- @field renderList RenderList
Screen = {}

--- @class HoverText : Widget
HoverText = {}

--- @class ConfirmDialog : Screen
ConfirmDialog = {}
--- @class Console : Widget
Console = {}
--- @class Docker : Screen
Docker = {}
--- @class History : Class
History = {}
--- @class MainScreen : Screen
MainScreen = {}
--- @class MainScreen2 : Screen
MainScreen2 = {}
--- @class Run : Class
Run = {}
--- @class ScreenSaver : Screen
ScreenSaver = {}
--- @class Suspend : Screen
Suspend = {}
--- @class SystemUpdate : Screen
SystemUpdate = {}
--- @class TextLog : Class
TextLog = {}
--- @class Unlock : Screen
Unlock = {}
--- @class WeatherGraphs : Screen
WeatherGraphs = {}
--- @class WeatherTrends : Screen
WeatherTrends = {}

-- Globals defined in .config/disorganiser/config.lua
--- @table
imap = {}
--- @table
ipaddr = {}
--- @table
secret = {}


-- Optional globals set from console.

--- @boolean Keep screensave from starting.
caffine = false
--- @boolean Should hover text show?
showHoverText = true
--- @integer Number of hours to show on weather grahps
hours = 24